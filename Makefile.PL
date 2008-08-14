use 5.008007;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Sub::ParamLoader',
    VERSION_FROM      => 'lib/Sub/ParamLoader.pm', # finds $VERSION
    PREREQ_PM         => {'Tie::Hash::KeysMask'=>0.01},
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Sub/ParamLoader.pm', # retrieve abstract from module
       AUTHOR         => 'Josef Schoenbrunner <j.schoenbrunner@schule.at>') : (),
       ABSTRACT       => 'Map named argument list into a hash modified according to a rule',
    )
  );
