

use "lib/fs.yap"

fn main()
{
    put listing = FS::Dir("./");

    put i = 0;
    lab loop;
        jump done ~ i == Dyn::Size(listing);
        put dirent = Dyn::Ptr(listing).i;
        print("name: %s\n", [dirent.FS::Dir::Ent::NAME]);
        print("type: %d\n", [dirent.FS::Dir::Ent::TYPE]);

        put i = i + 1;
        jump loop;
    lab done;

}



