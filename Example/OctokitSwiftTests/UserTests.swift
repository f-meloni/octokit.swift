import XCTest
import Nocilla
import Octokit

class UserTests: XCTestCase {
    override func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
    }

    override func tearDown() {
        super.tearDown()
        LSNocilla.sharedInstance().clearStubs()
        LSNocilla.sharedInstance().stop()
    }

    func testReadingUserURLRequest() {
        let kit = Octokit()
        let request = UserRouter.ReadUser("mietzmithut", kit).URLRequest
        XCTAssertEqual(request.URL, NSURL(string: "https://api.github.com/users/mietzmithut")!)
    }

    func testReadingAuthenticatedUserURLRequest() {
        let kit = Octokit(TokenConfiguration(token: "12345"))
        let request = UserRouter.ReadAuthenticatedUser(kit).URLRequest
        XCTAssertEqual(request.URL, NSURL(string: "https://api.github.com/user?access_token=12345")!)
    }

    func testGettingUser() {
        let username = "mietzmithut"
        if let json = Helper.stringFromFile("user_mietzmithut") {
            stubRequest("GET", "https://api.github.com/users/mietzmithut").andReturn(200).withHeaders(["Content-Type": "application/json"]).withBody(json)
            let expectation = expectationWithDescription("\(username)")
            Octokit().user(username) { user in
                XCTAssertEqual(user.login, username)
                expectation.fulfill()
            }
            waitForExpectationsWithTimeout(1) { (error) in
                XCTAssertNil(error, "\(error)")
            }
        } else {
            XCTFail("json shouldn't be nil")
        }
    }

    func testGettingAuthenticatedUser() {
        if let json = Helper.stringFromFile("user_me") {
            stubRequest("GET", "https://api.github.com/user?access_token=token").andReturn(200).withHeaders(["Content-Type": "application/json"]).withBody(json)
            let expectation = expectationWithDescription("me")
            Octokit().me() { user in
                XCTAssertEqual(user.login, "pietbrauer")
                expectation.fulfill()
            }
            waitForExpectationsWithTimeout(10) { (error) in
                XCTAssertNil(error, "\(error)")
            }
        } else {
            XCTFail("json shouldn't be nil")
        }
    }

    // MARK: Model Tests

    func testUserParsingFullUser() {
        let subject = User(Helper.JSONFromFile("user_me"))
        XCTAssertEqual(subject.login, "pietbrauer")
        XCTAssertEqual(subject.id, 759730)
        XCTAssertEqual(subject.avatarURL, "https://avatars.githubusercontent.com/u/759730?v=3")
        XCTAssertEqual(subject.gravatarID, "")
        XCTAssertEqual(subject.type, "User")
        XCTAssertEqual(subject.name, "Piet Brauer")
        XCTAssertEqual(subject.company, "XING AG")
        XCTAssertEqual(subject.blog, "xing.to/PietBrauer")
        XCTAssertEqual(subject.location, "Hamburg")
        XCTAssertNil(subject.email)
        XCTAssertEqual(subject.numberOfPublicRepos, 6)
        XCTAssertEqual(subject.numberOfPublicGists, 10)
        XCTAssertEqual(subject.numberOfPrivateRepos!, 4)
    }

    func testUserParsingMinimalUser() {
        let subject = User(Helper.JSONFromFile("user_mietzmithut"))
        XCTAssertEqual(subject.login, "mietzmithut")
        XCTAssertEqual(subject.id, 4672699)
        XCTAssertEqual(subject.avatarURL, "https://avatars.githubusercontent.com/u/4672699?v=3")
        XCTAssertEqual(subject.gravatarID, "")
        XCTAssertEqual(subject.type, "User")
        XCTAssertEqual(subject.name, "Julia Kallenberg")
        XCTAssertEqual(subject.company, "")
        XCTAssertEqual(subject.blog, "")
        XCTAssertEqual(subject.location, "Hamburg")
        XCTAssertNil(subject.email)
        XCTAssertEqual(subject.numberOfPublicRepos, 7)
        XCTAssertEqual(subject.numberOfPublicGists, 0)
        XCTAssertNil(subject.numberOfPrivateRepos)
    }
}