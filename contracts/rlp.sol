contract RLP {

  struct Gram {
    bytes1 lookahead;
    bytes1[] R;
  }

  mapping (bytes1 => Gram) lang;

  function decodeLanguage(bytes str) {
    uint i=0;
    bool started;
    while(i<str.length) {
      // Single byte between 0x00 and 0x7f
      if(str[i] >= byte(0x00) && str[i] <= byte(0x7f)) {
        if(str[i] == byte(0x01)) { // and
          // expect 2 things

        }
      } else if(str[i] >= byte(0x80) && str[i] <= byte(0xb7)) { // string with length = str[i]-byte(0x80)
      
      } else if(str[i] >= byte(0xb8) && str[i] <= byte(0xbf)) { // string with length which follows
      
      } else if(str[i] >= byte(0xc0) && str[i] <= byte(0xf7)) { // list with length = str[i]-byte(0xc0)
        var length = str[i] - byte(0xc0);
        
      } else { // legth of list will follow
      
      }
    }
  }

  function decodeLanguage2(bytes str) {
    decodeRules(str);
  }
  
  function decodeRules() internal {
    
  }

  function testRLP() {
    decodeLanguage("c3803d64c3643d64c3643e65c3653e65");
  }

}
