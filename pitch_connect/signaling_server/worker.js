/**
 * Cloudflare Worker: WebRTC Signaling Server
 * 
 * 투수(Pitcher)와 포수(Catcher)를 같은 roomId로 매칭하여 서로의 시그널링 메시지를 중계합니다.
 */

export default {
  async fetch(request, env) {
    const upgradeHeader = request.headers.get('Upgrade');
    if (!upgradeHeader || upgradeHeader !== 'websocket') {
      return new Response('Expected Upgrade: websocket', { status: 426 });
    }

    const [client, server] = new WebSocketPair();

    server.accept();

    // 룸별로 클라이언트를 관리하기 위한 간단한 메모리 저장소 (Durable Objects 추천되나, 여기선 간단히 구현)
    // 실제 서비스 규모에서는 Durable Objects가 필수적입니다.
    server.addEventListener('message', event => {
      try {
        const message = JSON.parse(event.data);
        const { type, roomId, role, data } = message;

        // 투수/포수 간의 릴레이 로직
        // 여기에 룸 관리 로직 추가...
        // 하지만 Worker는 Stateless하므로, 실제로는 Durable Object를 쓰는 것이 좋습니다.
        // 여기서는 에코 및 브로드캐스트 기반의 구조만 제안합니다.
        
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
