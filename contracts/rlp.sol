import "dapple/test.sol";

contract RLP is Test {

  mapping (bytes32 => bytes4) lang;

  function exec(bytes str) returns (uint result) {
    result = exec_(0, str);
    //@log the result is `uint result`
  }

  function exec_(uint j, bytes str) internal returns (uint) {
    uint i = j;
    bytes memory f;
    uint w;
    uint length;
    uint await = 0;
    uint tmp;
    while(i < str.length) {
      // Single byte between 0x00 and 0x7f
      if(str[i] >= byte(0x00) && str[i] <= byte(0x7f)) {
        //@log Single byte between 0x00 and 0x7f: `byte str[i]`
        if(f.length == 0) { // function not set
          f = new bytes(1);
          f[0] = str[i];
          await --;
        } else if(await > 1) { // currently only work with binary tries
          w = uint(str[i]);
          await --;
        } else {
          tmp = uint(str[i]);
          return execExpr(f, w, tmp);
        }
        i++;
      } else if(str[i] >= byte(0x80) && str[i] <= byte(0xb7)) { // string with length = str[i]-byte(0x80)
        //@log string with length `uint length`
        length = uint(str[i]) - 0x80;
        i++;
        if(f.length == 0 || length > 32) { throw; }
        else if(await > 1) {
          while (length > 0) {
            w += (0x0100**(--length))*uint(str[i++]);
          }
          await--;
        } else {
          while (length > 0) {
            tmp += (0x0100**(--length))*uint(str[i++]);
          }
          return execExpr(f,w,tmp);
        }
      } else if(str[i] >= byte(0xb8) && str[i] <= byte(0xbf)) { // string with length which follows
        throw; // because it would be an uint overflow
      } else if(str[i] >= byte(0xc0) && str[i] <= byte(0xf7)) { // list with length = str[i]-byte(0xc0)
        length = uint(str[i]) - 0xc0;
        //@log List with length `uint length`
        if( await == 0 ) {
          await = 3;
        } else if(await > 1) {
          w = exec_(i, str);
          i += (length);
          await--;
        } else {
          tmp = exec_(i, str);
          i += (length);
          return execExpr(f, w, tmp);
        }
        i++;
      } else { // legth of list will follow
        throw; // cannot handle big big big expresions
      }
    }
  }

  function execExpr(bytes memory f, uint w1, uint w2) returns (uint) {
    //@log exec `string string(f)`(`uint w1`,`uint w2`)
    if(sha3(f) == sha3("+")) { // this could be done more efficient
      return w1 + w2;
    } else if(sha3(f) == sha3("*")) {
      return w1 * w2;
    }
  }

  function test1p2() {
    // 1 + 2
    uint result = exec("\xc3\x2b\x01\x02");
    assertTrue(result == 3);
  }

  function test42p99() {
    // 42 + 99
    uint result = exec("\xc3\x2b\x2a\x63");
    assertTrue(result == 141);
  }

  function test300p1() {
    // 300 + 1
    uint result = exec("\xc5\x2b\x82\x01\x2c\x01");
    assertTrue(result == 301);
  }

  function test65536p1() {
    // 65536 + 1
    // 0x010000 + 1
    uint result = exec("\xc6\x2b\x83\x01\x00\x00\x01");
    assertTrue(result == 65537);
  }

  function test65535p1() {
    // 65535 + 1
    // 0xffff + 1
    uint result = exec("\xc5\x2b\x82\xff\xff\x01");
    assertTrue(result == 65536);
  }

  function test1p65535() {
    // 1 + 65535
    // 1 + 0xffff
    uint result = exec("\xc5\x2b\x01\x82\xff\xff");
    assertTrue(result == 65536);
  }

  function test1p1p1() {
    // 1 + ( 1 + 1)
    // ["+",1, ["+",1,1]]
    uint result = exec("\xc6\x2b\x01\xc3\x2b\x01\x01");
    assertTrue(result == 3);
  }

  function testBoss() {
    // (1+2)*(1+2)
    // rlp encode '["*",["+",1,2], ["+",1,2]]'
    uint result = exec("\xc9\x2a\xc3\x2b\x01\x02\xc3\x2b\x01\x02");
    assertTrue(result == 9);
  }

}
