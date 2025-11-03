import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ImageUpload {
  filename: string
  base64Data: string
  contentType?: string
}

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )

    const payload = await req.json()
    console.log('Upload request received')

    const { email, images, bucket = 'portfolio' } = payload

    // Validate required fields
    if (!email || !images || !Array.isArray(images) || images.length === 0) {
      return new Response(
        JSON.stringify({ 
          error: 'Missing required fields: email and images array' 
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Find user by email
    const { data: userData, error: userError } = await supabaseAdmin.auth.admin.listUsers()
    
    if (userError) {
      console.error('Error fetching users:', userError)
      return new Response(
        JSON.stringify({ error: 'Failed to fetch users' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const user = userData.users.find(u => u.email === email)

    if (!user) {
      console.error(`User not found with email: ${email}`)
      return new Response(
        JSON.stringify({ error: `User not found with email: ${email}` }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    console.log(`Uploading ${images.length} images for user: ${user.id} (${email})`)

    // Upload each image
    const uploadedUrls: string[] = []
    const errors: string[] = []

    for (let i = 0; i < images.length; i++) {
      const image: ImageUpload = images[i]
      
      if (!image.filename || !image.base64Data) {
        errors.push(`Image ${i}: Missing filename or base64Data`)
        continue
      }

      try {
        // Remove data URL prefix if present
        let base64String = image.base64Data
        if (base64String.includes('base64,')) {
          base64String = base64String.split('base64,')[1]
        }

        // Convert base64 to binary
        const binaryData = Uint8Array.from(atob(base64String), c => c.charCodeAt(0))

        // Generate unique filename
        const timestamp = Date.now()
        const sanitizedFilename = image.filename.replace(/[^a-zA-Z0-9.-]/g, '_')
        const filePath = `${user.id}/${timestamp}-${sanitizedFilename}`

        // Upload to storage
        const { data: uploadData, error: uploadError } = await supabaseAdmin.storage
          .from(bucket)
          .upload(filePath, binaryData, {
            contentType: image.contentType || 'image/jpeg',
            cacheControl: '3600',
            upsert: false
          })

        if (uploadError) {
          console.error(`Error uploading ${image.filename}:`, uploadError)
          errors.push(`${image.filename}: ${uploadError.message}`)
          continue
        }

        // Get public URL
        const { data: urlData } = supabaseAdmin.storage
          .from(bucket)
          .getPublicUrl(filePath)

        uploadedUrls.push(urlData.publicUrl)
        console.log(`Successfully uploaded: ${filePath}`)

      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error'
        console.error(`Error processing ${image.filename}:`, errorMsg)
        errors.push(`${image.filename}: ${errorMsg}`)
      }
    }

    return new Response(
      JSON.stringify({ 
        success: true,
        uploaded: uploadedUrls.length,
        urls: uploadedUrls,
        errors: errors.length > 0 ? errors : undefined
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error in upload-professional-images function:', error)
    const errorMessage = error instanceof Error ? error.message : 'Unknown error'
    return new Response(
      JSON.stringify({ error: errorMessage }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})
