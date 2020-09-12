//
//  MixesService.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/11/20.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

enum StorageKeys {
    static let mixes = "mixo.mixes"
}

protocol MixesService {
    var mixes: [Mix] { get }
    func fetchMixes(completion: @escaping ([Mix]) -> Void)
    func createMix(with track: MixTrack?)
    func update(mix: Mix)
    func editMix(_ id: String, with name: String)
    func removeMix(_ mix: Mix)
    func addToMix(id: String, track: MixTrack)
    func removeFromMix(track: MixTrack, mixId: String)
}

final class AnonymousMixesService: MixesService {
    var mixes: [Mix] {
        return []
    }

    static let shared = AnonymousMixesService()

    private let firestore = Firestore.firestore()

    private let storageService: StorageService

    init(storageService: StorageService = FileStorageService()) {
        self.storageService = storageService
    }

    func fetchMixes(completion: @escaping ([Mix]) -> Void) {
        firestore.collection("users").whereField("id", isEqualTo: Auth.auth().currentUser?.uid as Any).getDocuments() { querySnapshot, error in
            guard let userDocumentId = querySnapshot?.documents.first?.documentID else {
                return
            }
            self.firestore.collection("users").document(userDocumentId).collection("mixes").getDocuments() { querySnapshot, error in
                var mixes = [Mix]()
                for document in querySnapshot!.documents {
                    let mix = try! FirestoreDecoder().decode(Mix.self, from: document.data())
                    mixes.append(mix)
                }
                completion(mixes)
            }
        }
    }

    func createMix(with track: MixTrack?) {
        firestore.collection("users").whereField("id", isEqualTo: Auth.auth().currentUser?.uid as Any).getDocuments() { querySnapshot, error in
            guard let userDocumentId = querySnapshot?.documents.first?.documentID else {
                return
            }
            let newMixReference = self.firestore.collection("users").document(userDocumentId).collection("mixes").document()

            let mix = Mix(id: newMixReference.documentID, name: "My new mix", imageUrl: track?.album.images.first?.url, tracks: (track == nil) ? [] : [track])
            let mixData = try! FirestoreEncoder().encode(mix)

            newMixReference.setData(mixData)
        }
    }

    func addToMix(id: String, track: MixTrack) {
        firestore.collection("users").whereField("id", isEqualTo: Auth.auth().currentUser?.uid as Any).getDocuments() { querySnapshot, error in
            guard let userDocumentId = querySnapshot?.documents.first?.documentID else {
                return
            }
            let mixReference = self.firestore.collection("users").document(userDocumentId).collection("mixes").document(id)

            let trackData = try! FirestoreEncoder().encode(track)
            mixReference.updateData(["imageUrl": track.album.images.first?.url.absoluteString as Any])
            mixReference.setData(["tracks": FieldValue.arrayUnion([trackData])], merge: true)
        }
    }

    func removeFromMix(track: MixTrack, mixId: String) {
        firestore.collection("users").whereField("id", isEqualTo: Auth.auth().currentUser?.uid as Any).getDocuments() { querySnapshot, error in
            guard let userDocumentId = querySnapshot?.documents.first?.documentID else {
                return
            }

            let trackData = try! FirestoreEncoder().encode(track)

            let mixReference = self.firestore.collection("users").document(userDocumentId).collection("mixes").document(mixId)
            mixReference.updateData(["tracks": FieldValue.arrayRemove([trackData])])
        }
    }

    func removeMix(_ mix: Mix) {
        firestore.collection("users").whereField("id", isEqualTo: Auth.auth().currentUser?.uid as Any).getDocuments() { querySnapshot, error in
            guard let userDocumentId = querySnapshot?.documents.first?.documentID else {
                return
            }

            self.firestore.collection("users").document(userDocumentId).collection("mixes").document(mix.id).delete()
        }
    }

    func update(mix: Mix) {
        firestore.collection("users").whereField("id", isEqualTo: Auth.auth().currentUser?.uid as Any).getDocuments() { querySnapshot, error in
            guard let userDocumentId = querySnapshot?.documents.first?.documentID else {
                return
            }
            let mixReference = self.firestore.collection("users").document(userDocumentId).collection("mixes").document(mix.id)
            let mixData = try! FirestoreEncoder().encode(mix)

            mixReference.updateData(["tracks": mixData["tracks"] as Any])
        }
    }

    func editMix(_ id: String, with name: String) {
        firestore.collection("users").whereField("id", isEqualTo: Auth.auth().currentUser?.uid as Any).getDocuments() { querySnapshot, error in
            guard let userDocumentId = querySnapshot?.documents.first?.documentID else {
                return
            }
            let mixReference = self.firestore.collection("users").document(userDocumentId).collection("mixes").document(id)

            mixReference.updateData(["name": name])
        }
    }
}

// MARK: - Private methods
extension AnonymousMixesService {
    private func getMixes() -> [Mix] {
        return mixes
    }
}
