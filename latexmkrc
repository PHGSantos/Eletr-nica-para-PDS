# This shows how to use the pythontex package with latexmk

#  This version has a fudge on the latex and pdflatex commands that
#  allows the pythontex custom dependency to work even when $out_dir
#  is used to set the output directory.  Without the fudge (done by
#  trickery symbolic links) the custom dependency for using pythontex
#  will not be detected.

add_cus_dep('pytxcode', 'tex', 0, 'pythontex');
sub pythontex {
    # This subroutine is a fudge, because it from latexmk's point of
    # view, it makes the main .tex file depend on the .pytxcode file.
    # But it doesn't actually make the .tex file, but is used for its
    # side effects in creating other files.  The dependence is a way
    # of triggering the rule to be run whenever the .pytxcode file
    # changes, and to do this before running latex/pdflatex again.
    return system("pythontex \"$_[0]\"") ;
}


$pdflatex = 'internal mylatex %R %Z pdflatex --shell-escape %O %S';
$latex = 'internal mylatex %R %Z latex --shell-escape %O %S';
sub mylatex {
   my $root = shift;
   my $dir_string = shift;
   my $code = "$root.pytxcode";
   my $result = "pythontex-files-$root";
   if ($dir_string) {
      warn "mylatex: Making symlinks to fool cus_dep creation\n";
      unlink $code;
      if (-l $result) {
          unlink $result;
      }
      elsif (-d $result) {
         unlink glob "$result/*";
         rmdir $result;
      }
      symlink $dir_string.$code, $code;
      if ( ! -e $dir_string.$result ) { mkdir $dir_string.$result; }
      symlink $dir_string.$result, $result;
   }
   else {
      foreach ($code, $result) { if (-l) { unlink; } }
   }
   return system @_;
}


