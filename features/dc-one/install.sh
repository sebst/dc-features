#!/bin/sh
# This script was generated using Makeself 2.5.0
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="3899326476"
MD5="ccae9feae84a2ff19574bc91b3607c56"
SHA="8f25b8becc0129604d43587777376c4ad13cf7276b1448acd19ad1282a1f8729"
SIGNATURE=""
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"
export USER_PWD
ARCHIVE_DIR=`dirname "$0"`
export ARCHIVE_DIR

label="Devcontainer.com Feature: dc-one"
script="./entrypoint.sh"
scriptargs=""
cleanup_script=""
licensetxt=""
helpheader=""
targetdir="."
filesizes="3833"
totalsize="3833"
keep="y"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"
decrypt_cmd=""
skip="718"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

if test -d /usr/xpg4/bin; then
    PATH=/usr/xpg4/bin:$PATH
    export PATH
fi

if test -d /usr/sfw/bin; then
    PATH=$PATH:/usr/sfw/bin
    export PATH
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  PAGER=${PAGER:=more}
  if test x"$licensetxt" != x; then
    PAGER_PATH=`exec <&- 2>&-; which $PAGER || command -v $PAGER || type $PAGER`
    if test -x "$PAGER_PATH"; then
      echo "$licensetxt" | $PAGER
    else
      echo "$licensetxt"
    fi
    if test x"$accept" != xy; then
      while true
      do
        MS_Printf "Please type y to accept, n otherwise: "
        read yn
        if test x"$yn" = xn; then
          keep=n
          eval $finish; exit 1
          break;
        elif test x"$yn" = xy; then
          break;
        fi
      done
    fi
  fi
}

MS_diskspace()
{
	(
	df -k "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    # Test for ibs, obs and conv feature
    if dd if=/dev/zero of=/dev/null count=1 ibs=512 obs=512 conv=sync 2> /dev/null; then
        dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
        { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
          test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
    else
        dd if="$1" bs=$2 skip=1 2> /dev/null
    fi
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd "$@"
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 count=1 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
Makeself version 2.5.0
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive
  $0 --verify-sig key Verify signature agains a provided key id

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet               Do not print anything except error messages
  --accept              Accept the license
  --noexec              Do not run embedded script (implies --noexec-cleanup)
  --noexec-cleanup      Do not run embedded cleanup script
  --keep                Do not erase target directory after running
                        the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the target folder to the current user
  --chown               Give the target folder to the current user recursively
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory (absolute or relative)
                        This directory may undergo recursive chown (see --nochown).
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --ssl-pass-src src    Use the given src as the source of password to decrypt the data
                        using OpenSSL. See "PASS PHRASE ARGUMENTS" in man openssl.
                        Default is to prompt the user to enter decryption password
                        on the current terminal.
  --cleanup-args args   Arguments to the cleanup script. Wrap in quotes to provide
                        multiple arguments.
  --                    Following arguments will be passed to the embedded script${helpheader}
EOH
}

MS_Verify_Sig()
{
    GPG_PATH=`exec <&- 2>&-; which gpg || command -v gpg || type gpg`
    MKTEMP_PATH=`exec <&- 2>&-; which mktemp || command -v mktemp || type mktemp`
    test -x "$GPG_PATH" || GPG_PATH=`exec <&- 2>&-; which gpg || command -v gpg || type gpg`
    test -x "$MKTEMP_PATH" || MKTEMP_PATH=`exec <&- 2>&-; which mktemp || command -v mktemp || type mktemp`
	offset=`head -n "$skip" "$1" | wc -c | sed "s/ //g"`
    temp_sig=`mktemp -t XXXXX`
    echo $SIGNATURE | base64 --decode > "$temp_sig"
    gpg_output=`MS_dd "$1" $offset $totalsize | LC_ALL=C "$GPG_PATH" --verify "$temp_sig" - 2>&1`
    gpg_res=$?
    rm -f "$temp_sig"
    if test $gpg_res -eq 0 && test `echo $gpg_output | grep -c Good` -eq 1; then
        if test `echo $gpg_output | grep -c $sig_key` -eq 1; then
            test x"$quiet" = xn && echo "GPG signature is good" >&2
        else
            echo "GPG Signature key does not match" >&2
            exit 2
        fi
    else
        test x"$quiet" = xn && echo "GPG signature failed to verify" >&2
        exit 2
    fi
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    SHA_PATH=`exec <&- 2>&-; which shasum || command -v shasum || type shasum`
    test -x "$SHA_PATH" || SHA_PATH=`exec <&- 2>&-; which sha256sum || command -v sha256sum || type sha256sum`

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n "$skip" "$1" | wc -c | sed "s/ //g"`
    fsize=`cat "$1" | wc -c | sed "s/ //g"`
    if test $totalsize -ne `expr $fsize - $offset`; then
        echo " Unexpected archive size." >&2
        exit 2
    fi
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$SHA_PATH"; then
			if test x"`basename $SHA_PATH`" = xshasum; then
				SHA_ARG="-a 256"
			fi
			sha=`echo $SHA | cut -d" " -f$i`
			if test x"$sha" = x0000000000000000000000000000000000000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded SHA256 checksum." >&2
			else
				shasum=`MS_dd_Progress "$1" $offset $s | eval "$SHA_PATH $SHA_ARG" | cut -b-64`;
				if test x"$shasum" != x"$sha"; then
					echo "Error in SHA256 checksums: $shasum is different from $sha" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " SHA256 checksums are OK." >&2
				fi
				crc="0000000000";
			fi
		fi
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" != x"$crc"; then
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2
			elif test x"$quiet" = xn; then
				MS_Printf " CRC checksums are OK." >&2
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

MS_Decompress()
{
    if test x"$decrypt_cmd" != x""; then
        { eval "$decrypt_cmd" || echo " ... Decryption failed." >&2; } | eval "gzip -cd"
    else
        eval "gzip -cd"
    fi
    
    if test $? -ne 0; then
        echo " ... Decompression failed." >&2
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf -  2>&1 || { echo " ... Extraction failed." >&2; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. >&2; kill -15 $$; }
    fi
}

MS_exec_cleanup() {
    if test x"$cleanup" = xy && test x"$cleanup_script" != x""; then
        cleanup=n
        cd "$tmpdir"
        eval "\"$cleanup_script\" $scriptargs $cleanupargs"
    fi
}

MS_cleanup()
{
    echo 'Signal caught, cleaning up' >&2
    MS_exec_cleanup
    cd "$TMPROOT"
    rm -rf "$tmpdir"
    eval $finish; exit 15
}

finish=true
xterm_loop=
noprogress=n
nox11=y
copy=none
ownership=n
verbose=n
cleanup=y
cleanupargs=
sig_key=

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
	--accept)
	accept=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 20 KB
	echo Compression: gzip
	if test x"n" != x""; then
	    echo Encryption: n
	fi
	echo Date of packaging: Sat Sep 28 11:32:24 CEST 2024
	echo Built with Makeself version 2.5.0
	echo Build command was: "./makeself-2.5.0/makeself.sh \\
    \"--gzip\" \\
    \"--current\" \\
    \"--nox11\" \\
    \"--sha256\" \\
    \"/tmp/dc-one.XbvDhSoKhN/\" \\
    \"/home/bas/_Code/dc-features/features/dc-one/install.sh\" \\
    \"Devcontainer.com Feature: dc-one\" \\
    \"./entrypoint.sh\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"y" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
    echo CLEANUPSCRIPT=\"$cleanup_script\"
	echo archdirname=\".\"
	echo KEEP=y
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
    echo totalsize=\"$totalsize\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5sum\"
	echo SHAsum=\"$SHAsum\"
	echo SKIP=\"$skip\"
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n "$skip" "$0" | wc -c | sed "s/ //g"`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n "$skip" "$0" | wc -c | sed "s/ //g"`
	arg1="$2"
    shift 2 || { MS_Help; exit 1; }
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --verify-sig)
    sig_key="$2"
    shift 2 || { MS_Help; exit 1; }
    MS_Verify_Sig "$0"
    ;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
    cleanup_script=""
	shift
	;;
    --noexec-cleanup)
    cleanup_script=""
    shift
    ;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir="${2:-.}"
    shift 2 || { MS_Help; exit 1; }
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --chown)
        ownership=y
        shift
        ;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
	--ssl-pass-src)
	if test x"n" != x"openssl"; then
	    echo "Invalid option --ssl-pass-src: $0 was not encrypted with OpenSSL!" >&2
	    exit 1
	fi
	decrypt_cmd="$decrypt_cmd -pass $2"
    shift 2 || { MS_Help; exit 1; }
	;;
    --cleanup-args)
    cleanupargs="$2"
    shift 2 || { MS_Help; exit 1; }
    ;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir="$TMPROOT"/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    export USER_PWD="$tmpdir"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if test -t 1; then  # Do we have a terminal on stdout?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0 >&2
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -e "$0 --xwin $initargs"
                else
                    exec $XTERM -e "./$0 --xwin $initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp "$tmpdir" || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n "$skip" "$0" | wc -c | sed "s/ //g"`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 20 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
    # Decrypting with openssl will ask for password,
    # the prompt needs to start on new line
	if test x"n" = x"openssl"; then
	    echo "Decrypting and uncompressing $label..."
	else
        MS_Printf "Uncompressing $label"
	fi
fi
res=3
if test x"$keep" = xn; then
    trap MS_cleanup 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace "$tmpdir"`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 20; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (20 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | MS_Decompress | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$export_conf" = x"y"; then
        MS_BUNDLE="$0"
        MS_LABEL="$label"
        MS_SCRIPT="$script"
        MS_SCRIPTARGS="$scriptargs"
        MS_ARCHDIRNAME="$archdirname"
        MS_KEEP="$KEEP"
        MS_NOOVERWRITE="$NOOVERWRITE"
        MS_COMPRESS="$COMPRESS"
        MS_CLEANUP="$cleanup"
        export MS_BUNDLE MS_LABEL MS_SCRIPT MS_SCRIPTARGS
        export MS_ARCHDIRNAME MS_KEEP MS_NOOVERWRITE MS_COMPRESS
    fi

    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi

MS_exec_cleanup

if test x"$keep" = xn; then
    cd "$TMPROOT"
    rm -rf "$tmpdir"
fi
eval $finish; exit $res
‹ (Í÷fíkWÛÆ2Ÿı+&bŒy„{İ:-’pn9Æi{/¡ Kk{ƒ,©Z‰G÷·ß™}È’cbÚ›öœ¦ŞA^ÍÎÎ{fg§á{v²Óä&x˜:bøè‹5Û[[ô·¹½µVü+ÇÆÚÚ£ææÓí­íÍ§›4ßÜØXk>‚µGÂÈDê&HJÏŸ…›õş/:72‘4z<D¸ûÑ!ØvÅIÔç“Ï‰v,IØ5Oé1æ1ë»< ç0ò‚¨×c‰ú‘…‚¥•JãÒM>»ô¢0uyÈÇ‹F1Œ6rC¸ç5K.¹Ç„ƒ›{³`àÊ£ùø¿†cüŸ‡èA`ûğ/fø?>nLúÿÓõÍ¹ÿÿµı?a®…Átw:/öñŸİ—mk±æÇD'˜il7ñ†<e^š%¬nUØu%)ìíÿp°sxö¼stØİ?ÜkWÃ(Dh–¸^Ê/Yµ€;tG¬]E&«­ç<f½‹#ÁÓ(¹iWë‰´ñ)$rî&7‡„ÇZüHøî¬É·oÜtxî±—l¼èSà®›Xú<
|–´«RºAä¹É¸:˜ğÑÜ5Ìl‰†â®—,<Â7ƒl„I¼]µm=…‚â}x''€ÈÜï¶ì;Úÿ…_j›2‘Ş¬Ùÿ<]yç”ÿÖáôôH‡,¬ <{²Rc}¨¶Ûm8Ùït:§p§¸XzCj—n±XKÂªh)Xj'¢ğ=÷AP
H¹gˆ‡~”Œ\„üÙù·ó¿«ğ7†åÈ4€´¿f¥Ï+Ÿy› }º°_30'FYzî€‰×\Úµº‘Ø	T,õB%©hx®M¼Ï=¢Ññ’´
c¾ïÇ»Ò®U'Wë’,¹æ)äĞû¼,	à¥±F˜¬?{Ò|è¸ô¬´~'R\yNéí¿)-c=)iĞ`ªÊP¶ğäIy×÷¿şÎ=ßÿªwÌfÅ.Æ¥´½øqá~“ïOï*E3?dÌ‡4aIä€§ëõÆZ‘ë +-Î {ÂZÁ‹tu²ö·1L@û(Z¤ aÊs•‰Uš‹©,€5aÍÖ*N¡ıY@z²Ğj¬ò&F(ÊMm;R± ºÇzÙ ÕÂ0ÿ&‰zu˜ˆtôvšd¬úøOÖjı%ßß …æ9ŒlS¬$Œ‰…şÔ·" g©y§£Éçõo=È†oo)œ|(ƒL×Õ×!D“Cc1,²QœŞ€Hqá ,)iiÿ:Æ+ÈÕâ<}™õŞ&AÛ¦i,Z†sG¥<Y!'”÷0sLfÁ;|0W0ÑĞ{O‰í/P·&,G}½5è…ĞO¢(
`çÍPĞÆX_Š×Ó©•á{:GÚBüçˆ\Á·k›F}¶-0Ì oŒ'd	Rx?Œ®l¬RP¢¹Îí—DÓ‹ƒîË·?œuşµØZ±v²"üƒKji¡_ ’¬»	8J•%Û¹3uKÁŒ²Œ“ºƒ3ª%pÊC‡Áò¦fÕ¾ûVËõYM'Û<ëæi·nÕ“¾Ö[ ÏÁç:…´Me{3„X²Éû“øs”¡Šs	Cd—Ì(=ÏÎ¤ô·WRÕ…Ü<KÛyº ¯ĞÎÒ~íÒ'«œv¡ùNVAÒ,©,šU\Ÿ.,Q~m¹Éèé¦UJû¬êm…‚M¾ºşÇÓ3z‡”æ„úÑUD®_òÏ‚o~Ö+ÍâÆåâGÍ1U€²*={ÅÃìú¬Ì Zâ>`V)%®.ivU¹˜•+‘â,Å
©«@9J6÷¼’×Ù6Õ²2–©ŸCä[?æ¾¨mæ&(¢ì˜ı³4ÎR¬ÇLæ/Ä2!%Æö#OĞ´R:(vTœ¬œ+Y--VïfÎHÛš%ñJıì{–Ó·²@Ó9éúƒyê›Eö.L¯÷­¢kM¯üK9ÆhgkˆY2¢,…‚Šé\ãèØZ6‘zb{Ú„ø"_"¼¦´ÿ.ÚbR¬$ à”rû’ÊcÉCb_â“ıœ€÷0_¥	×X.£Û‘'¼ÜDÃèj:Ñ%åÕ®†ÜN¾D—¯LÂmK“üœgÇ„À°È\ŠšUR0ß)¢‹_Wÿ‡‡üKw€gõ·6ŸNö¶šóşï×ÒÿÉ{4dZX×z1˜.0|¾O¬#ÒÊõ,8B[ºÃ¸gÁfêä×">ñÔ]Ûh_.ÌğÿÍÍÍ	ÿßÜÜ÷çıßßĞÿÍÍ¶ĞbEwîóÁsäŠñÅXŞıÍÚ†óÖØ¼5öe[c°‹–2>øíá–3Q]à¯é©TgZw%¹º 2oø;á™¨&À„˜.’— àsˆUàqŞ‹(DÈ™˜‹à$`c¨÷kÌÂ8Ó=Ú;jIŸät=:Ñ‡z7 /´ÔÕ>}0=½¢ˆqP_t¦v“ÍşñªW¤şR¼ÄÓÒ3°flêıPP4p8•°J ¦s´CI °Ç½'iÕœš9W=ˆÀ¿õï7Ö_üãŸ‡|ÿótòûŸõ­Íõyı÷•ÿ*Î'›¦ŠçÂ´nKÌ}ùòÿÂ‘üOöÿííIÿß^ß˜ûÿŸäÿäûäô˜yOŒœÖ¦\]xÃ„‹ÑMšFan.ò#—Ê>Š±¢e˜†S}uH|yK]âÈò²şÊÃ¡'–evO¥y, <t¢ _$ ÷÷ı(è’cL‡iÔ±ŠÙîN²ŞCµÃk÷‚®FÜ)»yí Às3¡já%ë{,¤d4ãX&ûKÚ Q`ø›ã[E~<Óíììî[p*¿^ ×´ÙÂ¼X%Ó³|€F#ú+7GÉø\Ä{ƒ¬^áYÎéÂ$ˆÏéÕ@^»$=pu7Ú©d´¼V‡ô­‹7ŒÀ’ˆ[yËNb-Ğ[#ÙS8Áx)§¨8=µòµt2P2ªäÃ4o`rĞ.	Æì¡%D!\˜C©P*ùö§òôCŞƒÇˆ,&É7& Z)øŒö°~¶*wZx¯¢ê}@¿£õ®\¹¡TPœ°>¿æb­-ûqp…v jÃ³Añ[%9^!_ˆÉ•U'h
döq ;¤bmÿ½Šry‹U	+ojµÁêuˆHîÄ‘9úìzU²K'N-<GºJ$"õy¸ª­ÁS+äá‹§ò°@@Q†
F&µzåWa
yÛZ\·ò)…¨¹ÕïÒ[ü×¢ëüÄÀõ}ÔH@-MJ_¤‘BJ—@èGœ¿<êì¿Ş9<Û=zuÔ9>GóGX<j&ÜÇÊ	17É)4)o[‹KôİhpåŞ`N=5'Et€“iÀ8d¸AùÒy~ zBS,­E	m£)&‚m‡øBÆ½Œ.…‘-´¹ ¤…×‚Jô(2¹vùZ‰O.¥VS÷Xš€%Ø®×ëêVÚøİÚÆÆÉÚ7tòÁ%w##p5?’r7W×WCª…·¥ş©+D€oüH"Õ…‰µ¨°¿éº©FİX±–^¶–^·–­:Í6éZmÉå!Ë=6$0>GÓ?‘šİÜ ¹#óW‹rÁğ E7¢dÉ$˜˜>´‹Æ“úü‚Á9ù¢4)[WºA‡y†Q‰LIğ’6dƒÎ¯\#.Š¹\îÛÇÊÜc•e@%ú?E¡5Eˆ3¤JÛ?>	Tı‰’tTTÜ¼æŠ›³O„Å¥ÀŠRÄ&rF9‰ˆ®%iéYS"Í$,Ä}"ÑŸiÜšUõzJ9ÔkÃ³)º*câ?<Q$“a½zì––¤AåŒäfß:h(F™ÕAVrY˜€°p®×L 
]A:Q
ç0«IeôÎ9Y€cúm‹ô&` >$8Ô„¼NÑJ(ä¸şîvF»•‚™l/~l¶ì*‘T½S¡†.–]ŒÚ}7P‰Ô—Õ:&tŸrEßzH¨7G.â£?-{ë»;óÕ
ò³©UüÂ4_¾X“-ë—“_N—ÛÎ²UZr×¼E]ùå4A›|gäl~—ÄŒ¶)TÓ|F0™3„´2ã‡Ffú*y£iéØ/˜*-Î¿=§‹vzÄè¯r
:xQ;•$ÏL-)ÃLjeºQ!:ôÓ¦*BİP…?bDù>ùƒŒf2¨ªx+YsU¢é1Uq
±˜@E…J*(vdI]¥#ÉÌ\ydæFÖ4”û|¨­Õ‰üÕÌ#¤™üHU¢şè·R·–Ú>Şix3ÉçİÂrn"ÔöÁÈ’±oHïã`ê·iÑÒRkYwd2Ôy¿°Ü:9i‰ØõXëôTC–‚î®Ÿ¬ñ™Ÿ$“ú‹&YßT)gHÀ»ª	ÇJÎdÈÈT4Jl˜£”şV Y¯ëd ßRÑÚúÒ"ÌâBF8?>xqpØ=_•OİıÎësú–ğ|ÿçƒ®,1u<÷W•Òõ	EC|‘¡ÍR:ĞN#»”<ğ!¯Ûiî" ¬‚ñ-pÜİ;zÛUÉ;2ù¥"ÆsF1Ö=²ÚÁ22S¸zn>ÆÈ'D„E–ºœ­ —˜(Je®â%'y\JRE{iÉTesÔPJÄŠ”:•	Šè&	näòpºQœÿ4Ê2LúÉªó‚]·äë¯“W$+şdDÄ›£b¶ÚÄ ÖËYVØ¬â½ÖS¥EH<ãæÖğQFÎRô.ÆBº*Ä’’Ñà;Œ1(AI–„WÑ_Ğ{‘ÏÚ´%K>¥ør•!“½„å6ÙGBuCóÙ5ó2™îËÙßÉ1 …‹èóÅfsó_„jàô3,50lÌKuqJƒªr ¤ıãCNûâw¦rÒâZ4¯ŒÚqİ÷óvÏú?àü|hÿw}}²ÿÓÜ\›÷şÚı_½©MÛ†½ıw»;‡ûg÷è5ĞluaÚ·-PÍÈÂ«{Fµâa²VĞÖ¸MLâ¹OÏÇ|ÌÇ|ÌÇ|ÌÇ|ÌÇ|ÌÇ|ÌÇ|ÌÇ|ÌÇ|˜ñ?©€/| P  