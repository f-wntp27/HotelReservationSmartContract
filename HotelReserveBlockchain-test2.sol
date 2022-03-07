// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract HotelReserveBlockchain {
    struct Reservation {
        string room;
        string timestamp;
        string owner;
    }

    uint _sizeOfMapping = 0;
    mapping (uint => Reservation) mappingReservation;
    mapping (uint => bytes32) mappingHash;
    mapping (bytes32 => bool) proof;

    event ReservationAdded(address from, Reservation reservation, bytes32 hashed);
    event ReservationError(address from, Reservation reservation, string reason);

    function recordProof(Reservation memory reservation) private {
        mappingReservation[_sizeOfMapping] = reservation;
        mappingHash[_sizeOfMapping++] = hashing(reservation);
        proof[hashing(reservation)] = true;
    }

    function addReservation(string memory room, string memory timestamp, string memory owner) public payable {
        Reservation memory newReservation = Reservation(room, timestamp, owner);
        if (checkReservation(newReservation)) {
            emit ReservationError(msg.sender, newReservation, "This reservation was added previously");
            payable(msg.sender).transfer(msg.value);
            return;
        }
        recordProof(newReservation);
        emit ReservationAdded(msg.sender, newReservation, hashing(newReservation));
    }

    function hashing(Reservation memory reservation) private pure returns(bytes32) {
        return keccak256(abi.encode(reservation.room, reservation.timestamp, reservation.owner));
    }

    function listAllReservations() public view returns(Reservation[] memory) {
        Reservation[] memory allReservation = new Reservation[](_sizeOfMapping);
        for(uint i = 0; i < _sizeOfMapping; i++) {
            allReservation[i] = mappingReservation[i];
        }
        return allReservation;
    }

    function checkReservation(Reservation memory reservation) public view returns(bool) {
        return proof[hashing(reservation)];
    }
}