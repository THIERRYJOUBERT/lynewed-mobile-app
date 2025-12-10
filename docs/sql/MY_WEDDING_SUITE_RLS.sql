-- ============================================
-- MY WEDDING SUITE - RLS POLICIES
-- Version: 2.0 | Date: 2025-12-10
-- ============================================

-- ----------------------------------------
-- 1. Policies pour wedding_guests
-- ----------------------------------------
CREATE POLICY "Bride can manage wedding guests" ON wedding_guests
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM weddings w 
    WHERE w.id = wedding_guests.wedding_id 
    AND w.bride_profile_id = auth.uid()
  )
);

-- ----------------------------------------
-- 2. Policies pour inspiration_albums
-- ----------------------------------------
-- Bride peut tout faire sur ses albums
CREATE POLICY "Bride can manage own albums" ON inspiration_albums
FOR ALL USING (bride_profile_id = auth.uid());

-- Pros peuvent voir les albums non-privés des mariages où ils participent
CREATE POLICY "Pros can see shared albums" ON inspiration_albums
FOR SELECT USING (
  is_private = false AND
  EXISTS (
    SELECT 1 FROM wedding_participants wp
    WHERE wp.wedding_id = inspiration_albums.wedding_id
    AND wp.professional_profile_id = auth.uid()
    AND wp.status = 'active'
  )
);

-- ----------------------------------------
-- 3. Policies pour saved_posts
-- ----------------------------------------
CREATE POLICY "Bride can manage saved posts" ON saved_posts
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM inspiration_albums ia
    WHERE ia.id = saved_posts.album_id
    AND ia.bride_profile_id = auth.uid()
  )
);

CREATE POLICY "Pros can see saved posts in shared albums" ON saved_posts
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM inspiration_albums ia
    JOIN wedding_participants wp ON wp.wedding_id = ia.wedding_id
    WHERE ia.id = saved_posts.album_id
    AND ia.is_private = false
    AND wp.professional_profile_id = auth.uid()
    AND wp.status = 'active'
  )
);

-- ----------------------------------------
-- 4. Policies pour album_images
-- ----------------------------------------
CREATE POLICY "Bride can manage album images" ON album_images
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM inspiration_albums ia
    WHERE ia.id = album_images.album_id
    AND ia.bride_profile_id = auth.uid()
  )
);

CREATE POLICY "Pros can see images in shared albums" ON album_images
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM inspiration_albums ia
    JOIN wedding_participants wp ON wp.wedding_id = ia.wedding_id
    WHERE ia.id = album_images.album_id
    AND ia.is_private = false
    AND wp.professional_profile_id = auth.uid()
    AND wp.status = 'active'
  )
);

-- ----------------------------------------
-- 5. Policies pour wedding_events
-- ----------------------------------------
CREATE POLICY "Bride can manage wedding events" ON wedding_events
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM weddings w 
    WHERE w.id = wedding_events.wedding_id 
    AND w.bride_profile_id = auth.uid()
  )
);

CREATE POLICY "Pros can see public events" ON wedding_events
FOR SELECT USING (
  is_public = true AND
  EXISTS (
    SELECT 1 FROM wedding_participants wp
    WHERE wp.wedding_id = wedding_events.wedding_id
    AND wp.professional_profile_id = auth.uid()
    AND wp.status = 'active'
  )
);

-- ----------------------------------------
-- 6. Policies pour wedding_expenses
-- ----------------------------------------
CREATE POLICY "Bride can manage wedding expenses" ON wedding_expenses
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM weddings w 
    WHERE w.id = wedding_expenses.wedding_id 
    AND w.bride_profile_id = auth.uid()
  )
);

-- ----------------------------------------
-- 7. Policies pour pro_wedding_notes
-- ----------------------------------------
CREATE POLICY "Pro can manage own notes" ON pro_wedding_notes
FOR ALL USING (professional_profile_id = auth.uid());

-- ----------------------------------------
-- 8. Policies pour chat_rooms (wedding_team) - NOUVEAU
-- Note: Ces policies s'ajoutent aux policies existantes pour private/public
-- ----------------------------------------

-- Bride peut voir ses wedding_team rooms
CREATE POLICY "Bride can see own wedding_team rooms" ON chat_rooms
FOR SELECT USING (
  type = 'wedding_team' AND
  EXISTS (
    SELECT 1 FROM weddings w 
    WHERE w.id = chat_rooms.wedding_id 
    AND w.bride_profile_id = auth.uid()
  )
);

-- Pros actifs peuvent voir les wedding_team rooms
CREATE POLICY "Active pros can see wedding_team rooms" ON chat_rooms
FOR SELECT USING (
  type = 'wedding_team' AND
  EXISTS (
    SELECT 1 FROM wedding_participants wp
    WHERE wp.wedding_id = chat_rooms.wedding_id
    AND wp.professional_profile_id = auth.uid()
    AND wp.status = 'active'
  )
);

-- ----------------------------------------
-- 9. Policies pour chat_messages dans wedding_team - NOUVEAU
-- ----------------------------------------

-- Bride peut envoyer des messages dans son wedding_team chat
CREATE POLICY "Bride can send messages in wedding_team" ON chat_messages
FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM chat_rooms cr
    JOIN weddings w ON w.id = cr.wedding_id
    WHERE cr.id = chat_messages.room_id
    AND cr.type = 'wedding_team'
    AND w.bride_profile_id = auth.uid()
  )
);

-- Pros actifs peuvent envoyer des messages dans wedding_team chat
CREATE POLICY "Active pros can send messages in wedding_team" ON chat_messages
FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM chat_rooms cr
    JOIN wedding_participants wp ON wp.wedding_id = cr.wedding_id
    WHERE cr.id = chat_messages.room_id
    AND cr.type = 'wedding_team'
    AND wp.professional_profile_id = auth.uid()
    AND wp.status = 'active'
  )
);

-- Participants peuvent lire les messages wedding_team
CREATE POLICY "Wedding team members can read messages" ON chat_messages
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM chat_rooms cr
    WHERE cr.id = chat_messages.room_id
    AND cr.type = 'wedding_team'
    AND (
      EXISTS (SELECT 1 FROM weddings w WHERE w.id = cr.wedding_id AND w.bride_profile_id = auth.uid())
      OR
      EXISTS (SELECT 1 FROM wedding_participants wp WHERE wp.wedding_id = cr.wedding_id AND wp.professional_profile_id = auth.uid() AND wp.status = 'active')
    )
  )
);

-- ============================================
-- STORAGE POLICIES
-- ============================================

-- wedding-albums: public read, authenticated write
CREATE POLICY "Authenticated users can upload to wedding-albums"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'wedding-albums');

CREATE POLICY "Anyone can view wedding-albums"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'wedding-albums');

CREATE POLICY "Users can delete own uploads in wedding-albums"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'wedding-albums' AND auth.uid()::text = (storage.foldername(name))[1]);

-- chat-documents: private, authenticated only
-- Structure: {room_id}/{filename}
CREATE POLICY "Authenticated can upload to chat-documents"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'chat-documents');

CREATE POLICY "Chat participants can view documents"
ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id = 'chat-documents' AND
  EXISTS (
    SELECT 1 FROM chat_room_participants crp
    WHERE crp.room_id::text = (storage.foldername(name))[1]
    AND crp.profile_id = auth.uid()
    AND crp.conversation_status IN ('active', 'archived')
  )
);

-- wedding-covers: public read, bride can write
CREATE POLICY "Authenticated users can upload covers"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'wedding-covers');

CREATE POLICY "Anyone can view covers"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'wedding-covers');

CREATE POLICY "Users can delete own covers"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'wedding-covers' AND auth.uid()::text = (storage.foldername(name))[1]);
