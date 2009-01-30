use 5.006000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Data::Pareto',
    VERSION_FROM      => 'lib/Data/Pareto.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Data/Pareto.pm', # retrieve abstract from module
       AUTHOR         => 'Przemyslaw Wesolek <jest@go.art.pl>') : ()),
);
