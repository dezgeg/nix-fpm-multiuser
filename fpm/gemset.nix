{
  arr-pm = {
    dependencies = ["cabin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07yx1g1nh4zdy38i2id1xyp42fvj4vl6i196jn7szvjfm0jx98hg";
      type = "gem";
    };
    version = "0.0.10";
  };
  backports = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ax5sqw30vdkvc7crjj2ikw9q0ayn86q2gb6yfzrkh865174vc2p";
      type = "gem";
    };
    version = "3.11.3";
  };
  cabin = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0b3b8j3iqnagjfn1261b9ncaac9g44zrx1kcg81yg4z9i513kici";
      type = "gem";
    };
    version = "0.9.0";
  };
  childprocess = {
    dependencies = ["ffi"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0a61922kmvcxyj5l70fycapr87gz1dzzlkfpq85rfqk5vdh3d28p";
      type = "gem";
    };
    version = "0.9.0";
  };
  clamp = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jb6l4scp69xifhicb5sffdixqkw8wgkk9k2q57kh2y36x1px9az";
      type = "gem";
    };
    version = "1.0.1";
  };
  dotenv = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1w891k0jvlw2fbwl06wq22sdmg6hb8m6p3wm4bf00zlb4zjasw1j";
      type = "gem";
    };
    version = "2.4.0";
  };
  ffi = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0zw6pbyvmj8wafdc7l5h7w20zkp1vbr2805ql5d941g2b20pk4zr";
      type = "gem";
    };
    version = "1.9.23";
  };
  fpm = {
    dependencies = ["arr-pm" "backports" "cabin" "childprocess" "clamp" "ffi" "json" "pleaserun" "ruby-xz" "stud"];
    source = {
      fetchSubmodules = false;
      rev = "c12678536f45b6ea564a07f9a0ff522215d476d1";
      sha256 = "15mz86jzywqs51q3s3fv6i14b0sy7apj45aafymksp1zy0y7gggv";
      type = "git";
      url = "git://github.com/dezgeg/fpm.git";
    };
    version = "1.10.0";
  };
  insist = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bw3bdwns14mapbgb8cbjmr0amvwz8y72gyclq04xp43wpp5jrvg";
      type = "gem";
    };
    version = "1.0.0";
  };
  io-like = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04nn0s2wmgxij3k760h3r8m1dgih5dmd9h4v1nn085yi824i5z6k";
      type = "gem";
    };
    version = "0.3.0";
  };
  json = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qmj7fypgb9vag723w1a49qihxrcf5shzars106ynw2zk352gbv5";
      type = "gem";
    };
    version = "1.8.6";
  };
  mustache = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1g5hplm0k06vwxwqzwn1mq5bd02yp0h3rym4zwzw26aqi7drcsl2";
      type = "gem";
    };
    version = "0.99.8";
  };
  pleaserun = {
    dependencies = ["cabin" "clamp" "dotenv" "insist" "mustache" "stud"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hgnrl67zkqaxmfkwbyscawj4wqjm7h8khpbj58s6iw54wp3408p";
      type = "gem";
    };
    version = "0.0.30";
  };
  ruby-xz = {
    dependencies = ["ffi" "io-like"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11bgpvvk0098ghvlxr4i713jmi2izychalgikwvdwmpb452r3ndw";
      type = "gem";
    };
    version = "0.2.3";
  };
  stud = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qpb57cbpm9rwgsygqxifca0zma87drnlacv49cqs2n5iyi6z8kb";
      type = "gem";
    };
    version = "0.0.23";
  };
}