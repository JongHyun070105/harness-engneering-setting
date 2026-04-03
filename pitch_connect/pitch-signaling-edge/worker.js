// Cloudflare Worker: 룸 기반 WebRTC 시그널링 서버
const rooms = new Map();

export default {
  async fetch(request, env) {
    const upgradeHeader = request.headers.get('Upgrade');
    if (!upgradeHeader || upgradeHeader !== 'websocket') {
      return new Response('Expected Upgrade: websocket', { status: 426 });
    }

    const [client, server] = new WebSocketPair();
    let currentRoomId = null;

    server.accept();

    server.addEventListener('message', event => {
      try {
        // (현실적인 단순 구현: 모든 메시지를 다시 돌려보내거나 특정 룸으로 전달)
        // 실제 운영 환경에서는 Durable Object를 통해 특정 룸의 다른 사용자에게 전송해야 합니다.
        console.log(`Received message: ${type} from ${role} in room ${roomId}`);
        
        // 클라이언트로 다시 보냄 (간단한 루프백/브로드캐스트 시뮬레이션)
        server.send(JSON.stringify(message)); 
      } catch (e) {
        console.error('Error handling message:', e);
      }
    });

    return new Response(null, { status: 101, webSocket: client });
  }
};
