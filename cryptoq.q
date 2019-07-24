\d .cryptoq
/ ==================================
/      Public API
/ ==================================
b64_encode:{
  /p:("";"==";"=")c:count[x] mod 3;
  // (.Q.b6 2 sv/: 6 cut (raze 0b vs/: x),(();0000b;00b)c),p
  (.Q.b6 2 sv/: 6 cut (raze 0b vs/: x),(2*c)#0b),#[c:(0;2;1)count[x] mod 3;"="]
 };

b64_decode:{
  d:(neg sum "="=x)_"c"$2 sv/:8 cut raze -6#/:0b vs/: .Q.b6?x;
  $[(10h =type d)&(1=count d);first d ;d]
 };

b64_json_encode:{ b64_encode .j.j x};

b64_json_decode:{
   d:.j.k b64_decode x;
   $[(10h =type d)&(1=count d);first d ;d]
 };

/ Returns SHA256 Hash of Msg
/ @param Msg [String]
/ @return Hexadecimal
sha256:{[Msg]
  Bin: .cryptoq_binary.string_to_bin Msg;
  MsgPadded: sha_message_padding Bin;
  nblocks: count [MsgPadded] div 512;
  i:0; hc:.cryptoq_binary.hex_to_bin@'H;
  while[i<nblocks; hc:sha_compression[MsgPadded (512*i)+til 512;hc];i:i+1];
  .cryptoq_binary.bin_to_hex (,/)hc
 };

/ Returns SHA256 Hash of Hex
/ @param Hex [String]
/ @return Hexadecimal
hexsha256:{[Msg]
  Bin: .cryptoq_binary.hexstring_to_bin Msg;
  MsgPadded: sha_message_padding Bin;
  nblocks: count [MsgPadded] div 512;
  i:0; hc:.cryptoq_binary.hex_to_bin@'H;
  while[i<nblocks; hc:sha_compression[MsgPadded (512*i)+til 512;hc];i:i+1];
  .cryptoq_binary.bin_to_hex (,/)hc
 };
 / Returns SHA256 Hash of Hex
/ @param Hex [Bytes]
/ @return Hexadecimal
byte1sha256:{[Msg]
  Bin: .cryptoq_binary.hex_to_bin Msg;
  MsgPadded: sha_message_padding Bin;
  nblocks: count [MsgPadded] div 512;
  i:0; hc:.cryptoq_binary.hex_to_bin@'H;
  while[i<nblocks; hc:sha_compression[MsgPadded (512*i)+til 512;hc];i:i+1];
  .cryptoq_binary.bin_to_hex (,/)hc
 };
 / Returns SHA256 Hash of Hex
/ @param Hex [Bytes]
/ @return Hexadecimal
bytesha256:{[Msg]
  Bin:  Msg;
  MsgPadded: sha_message_padding_byte Bin;
  nblocks: count [MsgPadded] div 64;
  i:0; hc:H;
  while[i<nblocks; hc:sha_compression_byte[MsgPadded (64*i)+til 64;hc];i:i+1];
  (,/)hc
 };

/ Returns SHA256 Hash of Bin
/ @param Bin [boolean array]
/ @return Hexadecimal
binsha256:{[Msg]
  Bin: Msg;
  MsgPadded: sha_message_padding Bin;
  nblocks: count [MsgPadded] div 512;
  i:0; hc:.cryptoq_binary.hex_to_bin@'H;
  while[i<nblocks; hc:sha_compression[MsgPadded (512*i)+til 512;hc];i:i+1];
  .cryptoq_binary.bin_to_hex (,/)hc
 };
/ HMAC function
/ @param Key (String) Key for hmac
/ @param Msg (String) Msg to hash
/ @param HashFunc (function) Hash funtion to use. Should accept string and return hex value
/ @param BlockSize (integer) Blocksize in bits
/ @return hexadecimal hmac value
hmac:{[Key; Msg; HashFunc; BlockSize]
  kp: raze 0b vs/:"x"$(Key;HashFunc Key)BlockSize<8*count Key:Key,();  /key_padded value will be stored in this
  if[BlockSize>c:count kp; kp: kp,(BlockSize- c)#0b];
  key_pads: kp<>/:BlockSize#/:(00110110b;01011100b); / 0x36,0x5c
  h1: HashFunc "c"$'2 sv/: 8 cut key_pads[0],raze 0b vs/:"x"$Msg,();
  HashFunc "c"$'2 sv/: 8 cut raze key_pads[1],0b vs/:h1
  };

/ HMAC MD5
hmac_md5:{[Key;Msg] hmac[Key;Msg;md5;512]};

/ HMAC SHA256
hmac_sha256:{[Key;Msg] hmac[Key;Msg;sha256;512]};

/ converts input msg to String
/ @param Msg (Hex|Char|String)
format:{[Msg]
  if[-4h = type Msg; :enlist "c"$Msg]; / hex atom -> string
  if[4h = type Msg; :"c"$Msg];  / hex list -> string
  if[10h = type Msg; :Msg]; / string
  if[-10h = type Msg; :enlist Msg]; / char -> String
 };

/ enlist Input if it is an atom else return Input
/ @param Data (any) Any Input type
/ @return (List)
maybe_enlist_data:{[Data] (Data;enlist Data)0>type Data};


/ ==================================
/      SHA256 Algo
/ ==================================

/ SHA 256 Constants
H:(0x6a09e667;0xbb67ae85;0x3c6ef372;0xa54ff53a;0x510e527f;0x9b05688c;0x1f83d9ab;0x5be0cd19);
K:(0x428a2f98; 0x71374491; 0xb5c0fbcf; 0xe9b5dba5; 0x3956c25b; 0x59f111f1; 0x923f82a4; 0xab1c5ed5; 0xd807aa98; 0x12835b01; 0x243185be; 0x550c7dc3; 0x72be5d74; 0x80deb1fe; 0x9bdc06a7; 0xc19bf174; 0xe49b69c1; 0xefbe4786; 0x0fc19dc6; 0x240ca1cc; 0x2de92c6f; 0x4a7484aa; 0x5cb0a9dc; 0x76f988da; 0x983e5152; 0xa831c66d; 0xb00327c8; 0xbf597fc7; 0xc6e00bf3; 0xd5a79147; 0x06ca6351; 0x14292967; 0x27b70a85; 0x2e1b2138; 0x4d2c6dfc; 0x53380d13; 0x650a7354; 0x766a0abb; 0x81c2c92e; 0x92722c85; 0xa2bfe8a1; 0xa81a664b; 0xc24b8b70; 0xc76c51a3; 0xd192e819; 0xd6990624; 0xf40e3585; 0x106aa070; 0x19a4c116; 0x1e376c08; 0x2748774c; 0x34b0bcb5; 0x391c0cb3; 0x4ed8aa4a; 0x5b9cca4f; 0x682e6ff3; 0x748f82ee; 0x78a5636f; 0x84c87814; 0x8cc70208; 0x90befffa; 0xa4506ceb; 0xbef9a3f7; 0xc67178f2);

/ SHA 256 Functions
rrotate:.cryptoq_binary.rrotate;
rshift:.cryptoq_binary.rshift;
sch:{(x&y) <> z& not x};
smaj:{(x&y)<>(x&z)<>y&z};
ssig1:{(<>) over rrotate[x;]each 2 13 22};
ssig2:{(<>) over rrotate[x;]each 6 11 25};
ssig3:{rrotate[x;7] <> rrotate[x;18] <> rshift[x;3]};
ssig4:{rrotate[x;17] <> rrotate[x;19] <> rshift[x;10]};

/ pad message
sha_message_padding:{[Bin] raze Bin,1b,#[512-mod[65+c;512];0b], -64#0b vs c:count Bin };
sha_message_padding_byte:{[Bin] .cryptoq_binary.bin_to_hex sha_message_padding .cryptoq_binary.hex_to_bin Bin };

/ returns words for block
sha_block_words:{[Block]
  W:32 cut Block;
  first ({m:x 0;i: x 1; (m,enlist (.cryptoq_binary.bin_modulo/)(ssig4[m i-2];m[i-7];ssig3[m i-15];m i-16) ;i+1)}/)[48;(W;16)]
 };

sha_block_words_byte:{[Block]
  W:4 cut Block;
  first ({m: x 0;i: x 1;  (m,enlist (.cryptoq_binary.byte_modulo/)( .cryptoq_binary.bin_to_hex ssig4[.cryptoq_binary.hex_to_bin m i-2]; m[i-7];.cryptoq_binary.bin_to_hex ssig3[.cryptoq_binary.hex_to_bin m i-15]; m i-16) ;i+1)}/)[48;(W;16)]
 };

sha_compression:{[Block;hc]
  Words: sha_block_words Block;
  i:0;nhc:hc;
  while[i<64;nhc:sha_cal_hvals[Words;nhc;i];i:i+1];
  .cryptoq_binary.bin_modulo'[hc;nhc]
 };

 sha_compression_byte:{[Block;hc]
  Words: sha_block_words_byte Block;
  i:0;nhc:hc;
  while[i<64;nhc:sha_cal_hvals_byte[Words;nhc;i];i:i+1];
  .cryptoq_binary.byte_modulo'[hc;nhc]
 };

/ calculate new H constants for sha256 block
sha_cal_hvals:{[Words;hc;i]
   a:hc 0;b:hc 1;c:hc 2 ;d:hc 3;e:hc 4;f:hc 5;g:hc 6;h:hc 7;
   t1: (.cryptoq_binary.bin_modulo/)(h; ssig2[e];sch[e;f;g];.cryptoq_binary.hex_to_bin K[i];Words[i]);
   t2: .cryptoq_binary.bin_modulo[ssig1[a];smaj[a;b;c]];
   h:g; g:f; f:e; e:.cryptoq_binary.bin_modulo[d;t1]; d:c; c:b; b:a; a:.cryptoq_binary.bin_modulo[t1;t2];
   (a;b;c;d;e;f;g;h)
 };

 sha_cal_hvals_byte:{[Words;hc;i]
   a:hc 0;b:hc 1;c:hc 2 ;d:hc 3;e:hc 4;f:hc 5;g:hc 6;h:hc 7;
   t1: (.cryptoq_binary.byte_modulo/)(  h;   .cryptoq_binary.bin_to_hex ssig2[.cryptoq_binary.hex_to_bin e]; .cryptoq_binary.bin_to_hex sch[.cryptoq_binary.hex_to_bin e;.cryptoq_binary.hex_to_bin f;.cryptoq_binary.hex_to_bin g];   K[i]; Words[i]);
   t2: .cryptoq_binary.byte_modulo[.cryptoq_binary.bin_to_hex  ssig1[.cryptoq_binary.hex_to_bin a]; .cryptoq_binary.bin_to_hex smaj[.cryptoq_binary.hex_to_bin a;.cryptoq_binary.hex_to_bin b; .cryptoq_binary.hex_to_bin c]];
   h:g; g:f; f:e; e:.cryptoq_binary.byte_modulo[d;t1]; d:c; c:b; b:a; a:.cryptoq_binary.byte_modulo[t1;t2];
   (a;b;c;d;e;f;g;h)
 };
/ =============

\d .
