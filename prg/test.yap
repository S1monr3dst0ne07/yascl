

use "lib/ht.yap"
use "lib/debug.yap"


fn main()
{
    put ht = HT::Create();

    HT::Set(ht, "test_key", "test_value");
    HT::Set(ht, "normal_key", "normal_value");

    put out = HT::Get(ht, "normal_key");

    print("%s\n", [out]);



}



