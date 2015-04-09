$dbd_oracle_mm_opts = {
                        'VERSION_FROM' => 'lib/DBD/Oracle.pm',
                        'INC' => '-IZ:/orainstant32/sdk/include -IZ:/orainstant32/rdbms/demo -IC:\\strawberry\\perl\\vendor\\lib\\auto\\DBI',
                        'OBJECT' => '$(O_FILES)',
                        'ABSTRACT_FROM' => 'lib/DBD/Oracle.pm',
                        'AUTHOR' => 'Tim Bunce (dbi-users@perl.org)',
                        'dist' => {
                                    'PREOP' => '$(MAKE) -f Makefile.old distdir',
                                    'SUFFIX' => 'gz',
                                    'COMPRESS' => 'gzip -v9',
                                    'DIST_DEFAULT' => 'clean distcheck disttest tardist'
                                  },
                        'LIBS' => [
                                    '-LC:/STRAWB~2/env/USERPR~1/.cpanm/work/1410808515.2084/DBD-Oracle-1.74 -loci'
                                  ],
                        'DIR' => [],
                        'clean' => {
                                     'FILES' => 'xstmp.c Oracle.xsi dll.base dll.exp sqlnet.log libOracle.def mk.pm DBD_ORA_OBJ.*'
                                   },
                        'LICENSE' => 'perl',
                        'META_MERGE' => {
                                          'configure_requires' => {
                                                                    'DBI' => '1.51'
                                                                  },
                                          'build_requires' => {
                                                                'ExtUtils::MakeMaker' => 0,
                                                                'DBI' => '1.51',
                                                                'Test::Simple' => '0.90'
                                                              },
                                          'resources' => {
                                                           'homepage' => 'http://search.cpan.org/dist/DBD-Oracle',
                                                           'bugtracker' => {
                                                                             'web' => 'http://rt.cpan.org/Public/Dist/Display.html?Name=DBD-Oracle',
                                                                             'mailto' => 'bug-dbd-oracle at rt.cpan.org'
                                                                           },
                                                           'repository' => {
                                                                             'web' => 'http://github.com/yanick/DBD-Oracle/tree',
                                                                             'url' => 'git://github.com/yanick/DBD-Oracle.git',
                                                                             'type' => 'git'
                                                                           }
                                                         }
                                        },
                        'PREREQ_PM' => {
                                         'DBI' => '1.51'
                                       },
                        'NAME' => 'DBD::Oracle',
                        'DEFINE' => ' -Wall -Wno-comment -DUTF8_SUPPORT -DORA_OCI_VERSION=\\"11.2.0.3.0\\" -DORA_OCI_102 -DORA_OCI_112'
                      };
$dbd_oracle_mm_self = bless( {
                               'VERSION_FROM' => 'lib/DBD/Oracle.pm',
                               'INST_STATIC' => '$(INST_ARCHAUTODIR)\\$(BASEEXT)$(LIB_EXT)',
                               'CONFIG' => [
                                             'ar',
                                             'cc',
                                             'cccdlflags',
                                             'ccdlflags',
                                             'dlext',
                                             'dlsrc',
                                             'exe_ext',
                                             'full_ar',
                                             'ld',
                                             'lddlflags',
                                             'ldflags',
                                             'libc',
                                             'lib_ext',
                                             'obj_ext',
                                             'osname',
                                             'osvers',
                                             'ranlib',
                                             'sitelibexp',
                                             'sitearchexp',
                                             'so',
                                             'vendorarchexp',
                                             'vendorlibexp'
                                           ],
                               'DESTDIR' => '',
                               'INSTALLVENDORLIB' => 'C:\\strawberry\\perl\\vendor\\lib',
                               'LIBS' => $dbd_oracle_mm_opts->{'LIBS'},
                               'EQUALIZE_TIMESTAMP' => '$(ABSPERLRUN) -MExtUtils::Command -e eqtime --',
                               'C' => [
                                        'Oracle.c',
                                        'dbdimp.c',
                                        'oci8.c'
                                      ],
                               'PERL_ARCHIVE_AFTER' => '',
                               'INSTALLSITELIB' => 'C:\\strawberry\\perl\\site\\lib',
                               'MOD_INSTALL' => '$(ABSPERLRUN) -MExtUtils::Install -e "install([ from_to => {{@ARGV}}, verbose => \'$(VERBINST)\', uninstall_shadows => \'$(UNINST)\', dir_mode => \'$(PERM_DIR)\' ]);" --',
                               'NOECHO' => '@',
                               'TEST_S' => '$(ABSPERLRUN) -MExtUtils::Command::MM -e test_s --',
                               'AR' => 'ar',
                               'PERL_ARCHLIB' => 'C:\\strawberry\\perl\\lib',
                               'DESTINSTALLSITESCRIPT' => '$(DESTDIR)$(INSTALLSITESCRIPT)',
                               'ARGS' => {
                                           'LIBS' => $dbd_oracle_mm_opts->{'LIBS'},
                                           'clean' => $dbd_oracle_mm_opts->{'clean'},
                                           'dist' => $dbd_oracle_mm_opts->{'dist'},
                                           'VERSION_FROM' => 'lib/DBD/Oracle.pm',
                                           'INC' => '-IZ:/orainstant32/sdk/include -IZ:/orainstant32/rdbms/demo -IC:\\strawberry\\perl\\vendor\\lib\\auto\\DBI',
                                           'NAME' => 'DBD::Oracle',
                                           'LICENSE' => 'perl',
                                           'UNINST' => '1',
                                           'DIR' => $dbd_oracle_mm_opts->{'DIR'},
                                           'OBJECT' => '$(O_FILES)',
                                           'AUTHOR' => [
                                                         'Tim Bunce (dbi-users@perl.org)'
                                                       ],
                                           'ABSTRACT_FROM' => 'lib/DBD/Oracle.pm',
                                           'INSTALLDIRS' => 'vendor',
                                           'DEFINE' => ' -Wall -Wno-comment -DUTF8_SUPPORT -DORA_OCI_VERSION=\\"11.2.0.3.0\\" -DORA_OCI_102 -DORA_OCI_112',
                                           'PREREQ_PM' => $dbd_oracle_mm_opts->{'PREREQ_PM'},
                                           'META_MERGE' => $dbd_oracle_mm_opts->{'META_MERGE'}
                                         },
                               'DESTINSTALLVENDORMAN1DIR' => '$(DESTDIR)$(INSTALLVENDORMAN1DIR)',
                               'TEST_F' => '$(ABSPERLRUN) -MExtUtils::Command -e test_f --',
                               'INSTALLVENDORSCRIPT' => 'C:\\strawberry\\perl\\bin',
                               'DESTINSTALLARCHLIB' => '$(DESTDIR)$(INSTALLARCHLIB)',
                               'MAN1PODS' => {},
                               'MV' => '$(ABSPERLRUN) -MExtUtils::Command -e mv --',
                               'MAN1EXT' => '1',
                               'FALSE' => '$(ABSPERLRUN)  -e "exit 1" --',
                               'COMPRESS' => 'gzip --best',
                               'LDFLAGS' => '-s -L"C:\\strawberry\\perl\\lib\\CORE" -L"C:\\strawberry\\c\\lib"',
                               'PERL' => 'C:\\strawberry\\perl\\bin\\perl.exe',
                               'ZIPFLAGS' => '-r',
                               'PL_FILES' => {},
                               'MAKE' => 'dmake',
                               'MAKEFILE_OLD' => 'Makefile.old',
                               'PERLPREFIX' => 'C:\\strawberry\\perl',
                               'FULLPERLRUNINST' => '$(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"',
                               'OSNAME' => 'MSWin32',
                               'CCCDLFLAGS' => ' ',
                               'ABSPERL' => '$(PERL)',
                               'DESTINSTALLVENDORSCRIPT' => '$(DESTDIR)$(INSTALLVENDORSCRIPT)',
                               'dist' => $dbd_oracle_mm_opts->{'dist'},
                               'INST_AUTODIR' => '$(INST_LIB)\\auto\\$(FULLEXT)',
                               'NAME' => 'DBD::Oracle',
                               'XS' => {
                                         'Oracle.xs' => 'Oracle.c'
                                       },
                               'HAS_LINK_CODE' => 1,
                               'DEFINE_VERSION' => '-D$(VERSION_MACRO)=\\"$(VERSION)\\"',
                               'INST_DYNAMIC' => '$(INST_ARCHAUTODIR)\\$(DLBASE).$(DLEXT)',
                               'LIBC' => '',
                               'INSTALLDIRS' => 'vendor',
                               'SKIPHASH' => {},
                               'DESTINSTALLSCRIPT' => '$(DESTDIR)$(INSTALLSCRIPT)',
                               'DESTINSTALLSITEMAN3DIR' => '$(DESTDIR)$(INSTALLSITEMAN3DIR)',
                               'SITEARCHEXP' => 'C:\\strawberry\\perl\\site\\lib',
                               'DESTINSTALLSITEBIN' => '$(DESTDIR)$(INSTALLSITEBIN)',
                               'ABSTRACT_FROM' => 'lib/DBD/Oracle.pm',
                               'INST_BIN' => 'blib\\bin',
                               'META_MERGE' => $dbd_oracle_mm_opts->{'META_MERGE'},
                               'INSTALLSITESCRIPT' => 'C:\\strawberry\\perl\\site\\bin',
                               'INSTALLSCRIPT' => 'C:\\strawberry\\perl\\bin',
                               'INSTALLVENDORMAN3DIR' => '$(INSTALLMAN3DIR)',
                               'FULLPERLRUN' => '$(FULLPERL)',
                               'DESTINSTALLVENDORMAN3DIR' => '$(DESTDIR)$(INSTALLVENDORMAN3DIR)',
                               'ABSPERLRUN' => '$(ABSPERL)',
                               'UNINST' => '1',
                               'DOC_INSTALL' => '$(ABSPERLRUN) -MExtUtils::Command::MM -e perllocal_install --',
                               'INSTALLBIN' => 'C:\\strawberry\\perl\\bin',
                               'ECHO' => '$(ABSPERLRUN) -l -e "print qq{{@ARGV}}" --',
                               'SITEPREFIX' => 'C:\\strawberry\\perl\\site',
                               'INSTALLSITEBIN' => 'C:\\strawberry\\perl\\site\\bin',
                               'LDLOADLIBS' => 'liboci.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libmoldname.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libkernel32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libuser32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libgdi32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libwinspool.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libcomdlg32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libadvapi32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libshell32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libole32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\liboleaut32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libnetapi32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libuuid.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libws2_32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libmpr.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libwinmm.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libversion.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libodbc32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libodbccp32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libcomctl32.a',
                               'MM_VERSION' => '6.98',
                               'PMLIBDIRS' => [
                                                'lib'
                                              ],
                               'VERSION' => '1.74',
                               'INSTALLVENDORBIN' => 'C:\\strawberry\\perl\\bin',
                               'TOUCH' => '$(ABSPERLRUN) -MExtUtils::Command -e touch --',
                               'CC' => 'gcc',
                               'LDFROM' => '$(OBJECT)',
                               'UMASK_NULL' => 'umask 0',
                               'VERBINST' => 0,
                               'XS_DEFINE_VERSION' => '-D$(XS_VERSION_MACRO)=\\"$(XS_VERSION)\\"',
                               'MACROSTART' => '',
                               'DLBASE' => '$(BASEEXT)',
                               'CCDLFLAGS' => ' ',
                               'NAME_SYM' => 'DBD_Oracle',
                               'PERM_DIR' => 755,
                               'RM_RF' => '$(ABSPERLRUN) -MExtUtils::Command -e rm_rf --',
                               'MAKEMAKER' => 'C:/strawberry/perl/lib/ExtUtils/MakeMaker.pm',
                               'SHAR' => 'shar',
                               'VENDORARCHEXP' => 'C:\\strawberry\\perl\\vendor\\lib',
                               'DESTINSTALLVENDORARCH' => '$(DESTDIR)$(INSTALLVENDORARCH)',
                               'BOOTDEP' => '',
                               'PERM_RW' => 644,
                               'SO' => 'dll',
                               'AUTHOR' => $dbd_oracle_mm_self->{'ARGS'}{'AUTHOR'},
                               'LDDLFLAGS' => '-mdll -s -L"C:\\strawberry\\perl\\lib\\CORE" -L"C:\\strawberry\\c\\lib"',
                               'XS_VERSION_MACRO' => 'XS_VERSION',
                               'POSTOP' => '$(NOECHO) $(NOOP)',
                               'LD' => 'g++',
                               'INSTALLMAN3DIR' => 'none',
                               'DESTINSTALLMAN1DIR' => '$(DESTDIR)$(INSTALLMAN1DIR)',
                               'MM_Win32_VERSION' => '6.98',
                               'MAN3PODS' => {},
                               'DESTINSTALLSITELIB' => '$(DESTDIR)$(INSTALLSITELIB)',
                               'SUFFIX' => '.gz',
                               'UNINSTALL' => '$(ABSPERLRUN) -MExtUtils::Command::MM -e uninstall --',
                               'INSTALLSITEMAN1DIR' => '$(INSTALLMAN1DIR)',
                               'INC' => '-IZ:/orainstant32/sdk/include -IZ:/orainstant32/rdbms/demo -IC:\\strawberry\\perl\\vendor\\lib\\auto\\DBI',
                               'LIB_EXT' => '.a',
                               'MAKE_APERL_FILE' => 'Makefile.aperl',
                               'INSTALLVENDORMAN1DIR' => '$(INSTALLMAN1DIR)',
                               'INST_MAN3DIR' => 'blib\\man3',
                               'TEST_REQUIRES' => {},
                               'ABSPERLRUNINST' => '$(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"',
                               'PERLRUN' => '$(PERL)',
                               'INST_LIBDIR' => '$(INST_LIB)\\DBD',
                               'BSLOADLIBS' => '',
                               'INST_MAN1DIR' => 'blib\\man1',
                               'INSTALLMAN1DIR' => 'none',
                               'DEV_NULL' => '> NUL',
                               'CP_NONEMPTY' => '$(ABSPERLRUN) -MExtUtils::Command::MM -e cp_nonempty --',
                               'MAN3EXT' => '3',
                               'DESTINSTALLMAN3DIR' => '$(DESTDIR)$(INSTALLMAN3DIR)',
                               'EXPORT_LIST' => '$(BASEEXT).def',
                               'PREOP' => '$(NOECHO) $(NOOP)',
                               'ZIP' => 'zip',
                               'PERLMAINCC' => '$(CC)',
                               'VERSION_SYM' => '1_74',
                               'TRUE' => '$(ABSPERLRUN)  -e "exit 0" --',
                               'FIXIN' => 'pl2bat.bat',
                               'INST_ARCHAUTODIR' => '$(INST_ARCHLIB)\\auto\\$(FULLEXT)',
                               'MAP_TARGET' => 'perl',
                               'DESTINSTALLBIN' => '$(DESTDIR)$(INSTALLBIN)',
                               'DEFINE' => ' -Wall -Wno-comment -DUTF8_SUPPORT -DORA_OCI_VERSION=\\"11.2.0.3.0\\" -DORA_OCI_102 -DORA_OCI_112',
                               'INSTALLSITEMAN3DIR' => '$(INSTALLMAN3DIR)',
                               'DIST_DEFAULT' => 'tardist',
                               'DIST_CP' => 'best',
                               'TAR' => 'tar',
                               'CHMOD' => '$(ABSPERLRUN) -MExtUtils::Command -e chmod --',
                               'DESTINSTALLVENDORLIB' => '$(DESTDIR)$(INSTALLVENDORLIB)',
                               'clean' => $dbd_oracle_mm_opts->{'clean'},
                               'VENDORLIBEXP' => 'C:\\strawberry\\perl\\vendor\\lib',
                               'INSTALLVENDORARCH' => 'C:\\strawberry\\perl\\vendor\\lib',
                               'FULL_AR' => '',
                               'DIRFILESEP' => '\\\\',
                               'INSTALLPRIVLIB' => 'C:\\strawberry\\perl\\lib',
                               'FULLEXT' => 'DBD\\Oracle',
                               'PREFIX' => '$(VENDORPREFIX)',
                               'CI' => 'ci -u',
                               'ECHO_N' => '$(ABSPERLRUN)  -e "print qq{{@ARGV}}" --',
                               'LICENSE' => 'perl',
                               'DLSRC' => 'dl_win32.xs',
                               'FIRST_MAKEFILE' => 'Makefile',
                               'RESULT' => [
                                             '# This Makefile is for the DBD::Oracle extension to perl.
#
# It was generated automatically by MakeMaker version
# 6.98 (Revision: 69800) from the contents of
# Makefile.PL. Don\'t edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#
',
                                             '#   MakeMaker Parameters:
',
                                             '#     ABSTRACT_FROM => q[lib/DBD/Oracle.pm]',
                                             '#     AUTHOR => [q[Tim Bunce (dbi-users@perl.org)]]',
                                             '#     BUILD_REQUIRES => {  }',
                                             '#     CONFIGURE_REQUIRES => {  }',
                                             '#     DEFINE => q[ -Wall -Wno-comment -DUTF8_SUPPORT -DORA_OCI_VERSION=\\"11.2.0.3.0\\" -DORA_OCI_102 -DORA_OCI_112]',
                                             '#     DIR => []',
                                             '#     INC => q[-IZ:/orainstant32/sdk/include -IZ:/orainstant32/rdbms/demo -IC:\\strawberry\\perl\\vendor\\lib\\auto\\DBI]',
                                             '#     LIBS => [q[-LC:/STRAWB~2/env/USERPR~1/.cpanm/work/1410808515.2084/DBD-Oracle-1.74 -loci]]',
                                             '#     LICENSE => q[perl]',
                                             '#     META_MERGE => { configure_requires=>{ DBI=>q[1.51] }, build_requires=>{ ExtUtils::MakeMaker=>q[0], DBI=>q[1.51], Test::Simple=>q[0.90] }, resources=>{ homepage=>q[http://search.cpan.org/dist/DBD-Oracle], bugtracker=>{ web=>q[http://rt.cpan.org/Public/Dist/Display.html?Name=DBD-Oracle], mailto=>q[bug-dbd-oracle at rt.cpan.org] }, repository=>{ web=>q[http://github.com/yanick/DBD-Oracle/tree], url=>q[git://github.com/yanick/DBD-Oracle.git], type=>q[git] } } }',
                                             '#     NAME => q[DBD::Oracle]',
                                             '#     OBJECT => q[$(O_FILES)]',
                                             '#     PREREQ_PM => { DBI=>q[1.51] }',
                                             '#     TEST_REQUIRES => {  }',
                                             '#     VERSION_FROM => q[lib/DBD/Oracle.pm]',
                                             '#     clean => { FILES=>q[xstmp.c Oracle.xsi dll.base dll.exp sqlnet.log libOracle.def mk.pm DBD_ORA_OBJ.*] }',
                                             '#     dist => { PREOP=>q[$(MAKE) -f Makefile.old distdir], SUFFIX=>q[gz], COMPRESS=>q[gzip -v9], DIST_DEFAULT=>q[clean distcheck disttest tardist] }',
                                             '
# --- MakeMaker post_initialize section:'
                                           ],
                               'INSTALLSITEARCH' => 'C:\\strawberry\\perl\\site\\lib',
                               'XS_VERSION' => '1.74',
                               'USEMAKEFILE' => '-f',
                               'MKPATH' => '$(ABSPERLRUN) -MExtUtils::Command -e mkpath --',
                               'FULLPERL' => 'C:\\strawberry\\perl\\bin\\perl.exe',
                               'CONFIGURE_REQUIRES' => {},
                               'INST_LIB' => 'blib\\lib',
                               'PERL_CORE' => 0,
                               'INSTALLARCHLIB' => 'C:\\strawberry\\perl\\lib',
                               'PERL_SRC' => undef,
                               'TO_UNIX' => '$(NOECHO) $(NOOP)',
                               'TARFLAGS' => 'cvf',
                               'O_FILES' => [
                                              'Oracle.o',
                                              'dbdimp.o',
                                              'oci8.o'
                                            ],
                               'RM_F' => '$(ABSPERLRUN) -MExtUtils::Command -e rm_f --',
                               'INST_BOOT' => '$(INST_ARCHAUTODIR)\\$(BASEEXT).bs',
                               'PREREQ_PM' => $dbd_oracle_mm_opts->{'PREREQ_PM'},
                               'OBJ_EXT' => '.o',
                               'EXTRALIBS' => 'liboci.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libmoldname.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libkernel32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libuser32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libgdi32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libwinspool.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libcomdlg32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libadvapi32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libshell32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libole32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\liboleaut32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libnetapi32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libuuid.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libws2_32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libmpr.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libwinmm.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libversion.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libodbc32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libodbccp32.a C:\\strawberry\\c\\i686-w64-mingw32\\lib\\libcomctl32.a',
                               'MACROEND' => '',
                               'SITELIBEXP' => 'C:\\strawberry\\perl\\site\\lib',
                               'VENDORPREFIX' => 'C:\\strawberry\\perl\\vendor',
                               'PMLIBPARENTDIRS' => [
                                                      'lib'
                                                    ],
                               'DISTVNAME' => 'DBD-Oracle-1.74',
                               'PM' => {
                                         'lib/DBD/Oracle/Troubleshooting/Win64.pod' => 'blib\\lib\\DBD\\Oracle\\Troubleshooting\\Win64.pod',
                                         'lib/DBD/Oracle/Troubleshooting/Cygwin.pod' => 'blib\\lib\\DBD\\Oracle\\Troubleshooting\\Cygwin.pod',
                                         'lib/DBD/Oracle/Troubleshooting/Sun.pod' => 'blib\\lib\\DBD\\Oracle\\Troubleshooting\\Sun.pod',
                                         'lib/DBD/Oracle/Troubleshooting/Macos.pod' => 'blib\\lib\\DBD\\Oracle\\Troubleshooting\\Macos.pod',
                                         'lib/DBD/Oracle/Troubleshooting/Linux.pod' => 'blib\\lib\\DBD\\Oracle\\Troubleshooting\\Linux.pod',
                                         'lib/DBD/Oracle/Troubleshooting/Win32.pod' => 'blib\\lib\\DBD\\Oracle\\Troubleshooting\\Win32.pod',
                                         'lib/DBD/Oracle.pm' => 'blib\\lib\\DBD\\Oracle.pm',
                                         'mk.pm' => '$(INST_LIB)\\DBD\\mk.pm',
                                         'lib/DBD/Oracle/Troubleshooting.pod' => 'blib\\lib\\DBD\\Oracle\\Troubleshooting.pod',
                                         'lib/DBD/Oracle/Object.pm' => 'blib\\lib\\DBD\\Oracle\\Object.pm',
                                         'lib/DBD/Oracle/GetInfo.pm' => 'blib\\lib\\DBD\\Oracle\\GetInfo.pm',
                                         'lib/DBD/Oracle/Troubleshooting/Vms.pod' => 'blib\\lib\\DBD\\Oracle\\Troubleshooting\\Vms.pod',
                                         'lib/DBD/Oracle/Troubleshooting/Aix.pod' => 'blib\\lib\\DBD\\Oracle\\Troubleshooting\\Aix.pod',
                                         'lib/DBD/Oracle/Troubleshooting/Hpux.pod' => 'blib\\lib\\DBD\\Oracle\\Troubleshooting\\Hpux.pod'
                                       },
                               'DESTINSTALLSITEARCH' => '$(DESTDIR)$(INSTALLSITEARCH)',
                               'H' => [
                                        'Oracle.h',
                                        'dbdimp.h',
                                        'dbivport.h',
                                        'ocitrace.h'
                                      ],
                               'DESTINSTALLVENDORBIN' => '$(DESTDIR)$(INSTALLVENDORBIN)',
                               'INST_ARCHLIBDIR' => '$(INST_ARCHLIB)\\DBD',
                               'LD_RUN_PATH' => '',
                               'WARN_IF_OLD_PACKLIST' => '$(ABSPERLRUN) -MExtUtils::Command::MM -e warn_if_old_packlist --',
                               'INST_ARCHLIB' => 'blib\\arch',
                               'PARENT_NAME' => 'DBD',
                               'PERLRUNINST' => '$(PERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"',
                               'MAKEFILE' => 'Makefile',
                               'BUILD_REQUIRES' => {},
                               'PERL_ARCHIVE' => '$(PERL_INC)\\libperl520.a',
                               'DLEXT' => 'xs.dll',
                               'RCS_LABEL' => 'rcs -Nv$(VERSION_SYM): -q',
                               'NOOP' => 'rem',
                               'AR_STATIC_ARGS' => 'cr',
                               'OSVERS' => '6.3',
                               'EXE_EXT' => '.exe',
                               'RANLIB' => 'rem',
                               'PERM_RWX' => 755,
                               'MM_REVISION' => 69800,
                               'DISTNAME' => 'DBD-Oracle',
                               'LINKTYPE' => 'dynamic',
                               'DESTINSTALLPRIVLIB' => '$(DESTDIR)$(INSTALLPRIVLIB)',
                               'PERL_LIB' => 'C:\\strawberry\\perl\\lib',
                               'BASEEXT' => 'Oracle',
                               'DESTINSTALLSITEMAN1DIR' => '$(DESTDIR)$(INSTALLSITEMAN1DIR)',
                               'INST_SCRIPT' => 'blib\\script',
                               'DIR' => $dbd_oracle_mm_opts->{'DIR'},
                               'ABSTRACT' => 'Oracle database driver for the DBI module',
                               'OBJECT' => '$(O_FILES)',
                               'LIBPERL_A' => 'libperl.a',
                               'VERSION_MACRO' => 'VERSION',
                               'PERL_INC' => 'C:\\strawberry\\perl\\lib\\CORE',
                               'CP' => '$(ABSPERLRUN) -MExtUtils::Command -e cp --'
                             }, 'PACK001' );