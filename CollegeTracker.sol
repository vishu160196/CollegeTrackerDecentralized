pragma solidity ^0.8.0;
import"../lib/strings.sol" ;
import "@openzeppelin/contracts/utils/Strings.sol";
contract CollegeTracker {
    using StringsUtil for string;
    address public centralAuth;

    constructor() public {
        centralAuth = msg.sender;
    }

    modifier onlyCentralAuth() {
        require(msg.sender == centralAuth, "Only centralAuth can call this.");
        _;
    }

    struct College {
        uint256 regNo;
        string name;
        address add;
        bool canAddStudents;
        uint256 studentCount;
    }

    struct Student {
        uint256 roll;
        string name;
        string contact;
        string course;
    }

    // map college eth address to college
    mapping(address => College) private colleges;

    // map college eth address to student map
    mapping(address => mapping(uint256 => Student)) private collegeStudents;

    modifier collegeDoesNotExist(address _add) {
        require(colleges[_add].add == address(0x0), "college with this address already exists");
        _;
    }

    modifier collegeExist(address _add) {
        require(colleges[_add].add != address(0x0), "college with this address does not exist");
        _;
    }

    modifier collegeCanAddStudent(){
        require(colleges[msg.sender].canAddStudents, "college with this address can not add students");
        _;
    }

    modifier studentDoesNotExistsInCollege(uint256 _roll){
        require(collegeStudents[msg.sender][_roll].roll == 0, Strings.toString(_roll).concat(" roll already exists in college"));
        _;
    }

    modifier studentExistsInCollege(address _add, uint256 _roll){
        require(collegeStudents[_add][_roll].roll != 0, Strings.toString(_roll).concat(" roll does not exist in college"));
        _;
    }

    modifier rollIsNonZero(uint256 _roll){
        require( _roll > 0, "roll number can't be 0");
        _;
    }

    function addNewCollege(
        string memory _name,
        address _add,
        uint256 _regNo
    ) public onlyCentralAuth collegeDoesNotExist(_add) {
        colleges[_add] = College(_regNo, _name, _add, false, 0);
    }
    function blockCollegeToAddNewStudents(address _add) public onlyCentralAuth collegeExist(_add){
        colleges[_add].canAddStudents = false;
    }
    function unBlockCollegeToAddNewStudents(address _add) public onlyCentralAuth collegeExist(_add){
        colleges[_add].canAddStudents = true;
    }

    function addNewStudentToCollege(string memory _sName, string memory _contact, string memory _course, uint256 _roll) public collegeExist(msg.sender) collegeCanAddStudent studentDoesNotExistsInCollege(_roll) rollIsNonZero(_roll){
        collegeStudents[msg.sender][_roll] = Student(_roll, _sName, _contact, _course);
        colleges[msg.sender].studentCount += 1;
    }
    function changeStudentCourse(uint256 _roll, string memory newCourse) public collegeExist(msg.sender) studentExistsInCollege(msg.sender, _roll){
        collegeStudents[msg.sender][_roll].course = newCourse;
    }

    function getNumberOfStudentsForCollege(address _add) public view collegeExist(_add) returns (uint256) {
        return colleges[_add].studentCount;
    }

    function viewStudentDetailsInCollege(address _add, uint256 _roll) public view collegeExist(_add) studentExistsInCollege(_add, _roll) returns (uint256, string memory, string memory, string memory){
        return (collegeStudents[_add][_roll].roll, collegeStudents[_add][_roll].name, collegeStudents[_add][_roll].contact, collegeStudents[_add][_roll].course);
    }

    function viewCollegeDetails(address _add) public view collegeExist(_add) returns (uint256,
        string memory,
        address,
        bool,
        uint256){
            return (colleges[_add].regNo, colleges[_add].name, colleges[_add].add, colleges[_add].canAddStudents, colleges[_add].studentCount);
    }
}
