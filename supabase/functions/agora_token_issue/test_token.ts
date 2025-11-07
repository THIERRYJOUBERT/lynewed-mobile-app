// Test de génération de token Agora
// Pour exécuter : deno run --allow-net test_token.ts

import { RtcTokenBuilder, RtcRole } from 'npm:agora-access-token';

// Credentials Agora
const appId = 'ddfcd5a017564aebb138e985fdf30bcd';
const appCertificate = '763b45433aab4642af34a5cad285c275';
const channelName = 'test-channel-123';
const uid = 0; // UID 0 = n'importe quel utilisateur
const role = RtcRole.PUBLISHER;
const expirationTimeInSeconds = 3600;

const currentTimestamp = Math.floor(Date.now() / 1000);
const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

console.log('Generating token with:');
console.log('  appId:', appId);
console.log('  appCertificate:', appCertificate);
console.log('  channelName:', channelName);
console.log('  uid:', uid);
console.log('  role:', role);
console.log('  currentTimestamp:', currentTimestamp);
console.log('  privilegeExpiredTs:', privilegeExpiredTs);
console.log('  expirationTimeInSeconds:', expirationTimeInSeconds);

try {
  const token = RtcTokenBuilder.buildTokenWithUid(
    appId,
    appCertificate,
    channelName,
    uid,
    role,
    privilegeExpiredTs
  );

  console.log('\n✅ Token generated successfully!');
  console.log('Token:', token);
  console.log('Token length:', token.length);
  console.log('Token prefix:', token.substring(0, 20));
} catch (error) {
  console.error('\n❌ Error generating token:', error);
}
