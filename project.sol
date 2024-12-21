// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PeerTutoring {
    struct Tutor {
        address tutorAddress;
        string name;
        string expertise;
        uint256 hourlyRate; // in wei
        bool available;
    }

    struct Booking {
        address student;
        address tutor;
        uint256 sessionTime;
        uint256 amountPaid;
    }

    mapping(address => Tutor) public tutors;
    Booking[] public bookings;

    event TutorRegistered(address tutorAddress, string name, string expertise, uint256 hourlyRate);
    event TutorAvailabilityUpdated(address tutorAddress, bool available);
    event SessionBooked(address student, address tutor, uint256 sessionTime, uint256 amountPaid);

    // Register as a tutor
    function registerTutor(string memory _name, string memory _expertise, uint256 _hourlyRate) public {
        require(tutors[msg.sender].tutorAddress == address(0), "Tutor already registered");

        tutors[msg.sender] = Tutor({
            tutorAddress: msg.sender,
            name: _name,
            expertise: _expertise,
            hourlyRate: _hourlyRate,
            available: true
        });

        emit TutorRegistered(msg.sender, _name, _expertise, _hourlyRate);
    }

    // Update tutor availability
    function updateAvailability(bool _available) public {
        require(tutors[msg.sender].tutorAddress != address(0), "Tutor not registered");

        tutors[msg.sender].available = _available;

        emit TutorAvailabilityUpdated(msg.sender, _available);
    }

    // Book a session with a tutor
    function bookSession(address _tutor, uint256 _sessionTime) public payable {
        Tutor memory tutor = tutors[_tutor];
        require(tutor.available == true, "Tutor is not available");
        require(msg.value == tutor.hourlyRate, "Incorrect payment amount");

        bookings.push(Booking({
            student: msg.sender,
            tutor: _tutor,
            sessionTime: _sessionTime,
            amountPaid: msg.value
        }));

        // Transfer payment to the tutor
        payable(_tutor).transfer(msg.value);

        emit SessionBooked(msg.sender, _tutor, _sessionTime, msg.value);
    }

    // Get the number of bookings
    function getTotalBookings() public view returns (uint256) {
        return bookings.length;
    }
}
