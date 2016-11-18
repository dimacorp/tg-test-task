import Foundation

final class PeerTable: Table {
    static func tableSpec(_ id: Int32) -> ValueBoxTable {
        return ValueBoxTable(id: id, keyType: .int64)
    }
    
    private let sharedEncoder = Encoder()
    private let sharedKey = ValueBoxKey(length: 8)
    
    private var cachedPeers: [PeerId: Peer] = [:]
    private var updatedPeerIds = Set<PeerId>()
    
    private func key(_ id: PeerId) -> ValueBoxKey {
        self.sharedKey.setInt64(0, value: id.toInt64())
        return self.sharedKey
    }
    
    func set(_ peer: Peer) {
        self.cachedPeers[peer.id] = peer
        self.updatedPeerIds.insert(peer.id)
    }
    
    func get(_ id: PeerId) -> Peer? {
        if let peer = self.cachedPeers[id] {
            return peer
        }
        if let value = self.valueBox.get(self.table, key: self.key(id)) {
            if let peer = Decoder(buffer: value).decodeRootObject() as? Peer {
                self.cachedPeers[id] = peer
                return peer
            }
        }
        return nil
    }
    
    override func clearMemoryCache() {
        self.cachedPeers.removeAll()
        self.updatedPeerIds.removeAll()
    }
    
    override func beforeCommit() {
        for peerId in self.updatedPeerIds {
            if let peer = self.cachedPeers[peerId] {
                self.sharedEncoder.reset()
                self.sharedEncoder.encodeRootObject(peer)
                
                self.valueBox.set(self.table, key: self.key(peerId), value: self.sharedEncoder.readBufferNoCopy())
            }
        }
        
        self.updatedPeerIds.removeAll()
    }
}
