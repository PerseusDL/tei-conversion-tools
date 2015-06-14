//i. Necessary Packages

import scala.xml._
import java.io._
import scala.util.matching.Regex
import scala.sys.process._

//I. Class to deal with legacy text: requires currentTransforms.txt to run

class LegacyPerseusText(
  val urn: String,
  val filePath: String,
  val who:String,
  val what:String,
  val when:String){

  def text:String = { 
    
    return scala.io.Source.fromFile(filePath).mkString
 
  }

    def easyEpidocFixes:String ={
    val epidocfixes = scala.io.Source.fromFile("currentTransforms.txt").getLines.toList.map(_ split "!!!") collect { case Array(k, v) => (k, v) } toMap
    def replace(a:String,b:String):String = a.replaceAll(b,epidocfixes(b))
    return epidocfixes.keys.foldLeft(text)(replace)
  }
  
}

//II. Other misc fixes

//High priority: 
//1) write logic to deal with revisionDesc
//2) write logic to add lang and urn attributes to body
//3)write logic to add edition or translation wrapper div
//4)add handling of ids -> xml:ids
//5)refine and complete logic to fix funder attributes
//6)test for XML integrity and EpiDoc compliance automatically
//7) add some of test logic from old code

//Low priority:
//1) write logic to deal with change in <date> and its attributes

//For XML: doesn't change &gt &lt or &amp

def html2uni(t:String):String ={
      val ent2uni = Map("&ymacr;"->"ȳ","&imacr;"->"ī","&omacr;"->"ō","&umacr;"->"ū","&amacr;"->"ā","&emacr;"->"ē","&breve;"->"˘","&abreve;"->"ă","&ograve;"->"ò","&AElig;"->"Æ","&verbar;"->"|","&dot;"->"˙","&equals;"->"=","&lsqb"->"[","&rsqb"->"]","&quot;"->"\"","&lpar;"->"(","&rpar;"->")","&apos;"->"'","&iexcl;"->"¡","&cent;"->"¢","&pound;"->"£","&curren;"->"¤","&yen;"->"¥","&brvbar;"->"¦","&sect;"->"§","&uml;"->"¨","&copy;"->"©","&ordf;"->"ª","&laquo;"->"«","&not;"->"¬","&reg;"->"®","&macr;"->"¯","&deg;"->"°","&plusmn;"->"±","&sup2;"->"²","&sup3;"->"³","&acute;"->"´","&micro;"->"µ","&para;"->"¶","&middot;"->"·","&cedil;"->"¸","&sup1;"->"¹","&ordm;"->"º","&raquo;"->"»","&frac14;"->"¼","&frac12;"->"½","&frac34;"->"¾","&iquest;"->"¿","&times;"->"×","&divide;"->"÷","&Agrave;"->"À","&Aacute;"->"Á","&Acirc;"->"Â","&Atilde;"->"Ã","&Auml;"->"Ä","&Aring;"->"Å","&AEl ig ;"->"Æ","&Ccedil;"->"Ç","&Egrave;"->"È","&Eacute;"->"É","&Ecirc;"->"Ê","&Euml;"->"Ë","&Igrave;"->"Ì","&Iacute;"->"Í","&Icirc;"->"Î","&Iuml;"->"Ï","&ETH;"->"Ð","&Ntilde;"->"Ñ","&Ograve;"->"Ò","&Oacute;"->"Ó","&Ocirc;"->"Ô","&Otilde;"->"Õ","&Ouml;"->"Ö","&Oslash;"->"Ø","&Ugrave;"->"Ù","&Uacute;"->"Ú","&Ucirc;"->"Û","&Uuml;"->"Ü","&Yacute;"->"Ý","&THORN;"->"Þ","&szlig;"->"ß","&agrave;"->"à","&aacute;"->"á","&acirc;"->"â","&atilde;"->"ã","&auml;"->"ä","&aring;"->"å","&aelig;"->"æ","&ccedil;"->"ç","&egrave;"->"è","&eacute;"->"é","&ecirc;"->"ê","&euml;"->"ë","&igrave;"->"ì","&iacute;"->"í","&icirc;"->"î","&iuml;"->"ï","&eth;"->"ð","&ntilde;"->"ñ","&ogra ve;"->"ò","&oacute;"->"ó","&ocirc;"->"ô","&otilde;"->"õ","&ouml;"->"ö","&oslash;"->"ø","&ugrave;"->"ù","&uacute;"->"ú","&ucirc;"->"û","&uuml;"->"ü","&yacute;"->"ý","&thorn;"->"þ","&yuml;"->"ÿ","&forall;"->"∀","&part;"->"∂","&exist;"->"∃","&empty;"->"∅","&nabla;"->"∇","&isin;"->"∈","&notin;"->"∉","&ni;"->"∋","&prod;"->"∏","&sum;"->"∑","&minus;"->"−","&lowast;"->"∗","&radic;"->"√","&prop;"->"∝","&infin;"->"∞","&ang;"->"∠","&and;"->"∧","&or;"->"∨","&cap;"->"∩","&cup;"->"∪","&int;"->"∫","&there4;"->"∴","&sim;"->"∼","&cong;"->"≅","&asymp;"->"≈","&ne;"->"≠","&equiv;"->"≡","&le;"->"≤","&ge;"->"≥","&sub;"->"⊂","&sup;"->"� � �","&nsub;"->"⊄","&sube;"->"⊆","&supe;"->"⊇","&oplus;"->"⊕","&otimes;"->"⊗","&perp;"->"⊥","&sdot;"->"⋅","&Alpha;"->"Α","&Beta;"->"Β","&Gamma;"->"Γ","&Delta;"->"Δ","&Epsilon;"->"Ε","&Zeta;"->"Ζ","&Eta;"->"Η","&Theta;"->"Θ","&Iota;"->"Ι","&Kappa;"->"Κ","&Lambda;"->"Λ","&Mu;"->"Μ","&Nu;"->"Ν","&Xi;"->"Ξ","&Omicron;"->"Ο","&Pi;"->"Π","&Rho;"->"Ρ","&sigmaf;"->"ς","&Sigma;"->"Σ","&Tau;"->"Τ","&Upsilon;"->"Υ","&Phi;"->"Φ","&Chi;"->"Χ","&Psi;"->"Ψ","&Omega;"->"Ω","&alpha;"->"α","&beta;"->"β","&gamma;"->"γ","&delta;"->"δ","&epsilon;"->"ε","&zeta;"->"ζ","&eta;"->"η","&theta;"->"θ","&iota;"->"ι","&kappa;"->"κ","&lambda;"->"λ","&mu;"->"μ","&a mp; ;nu;"->"ν","&xi;"->"ξ","&omicron;"->"ο","&pi;"->"π","&rho;"->"ρ","&sigmaf;"->"ς","&sigma;"->"σ","&tau;"->"τ","&upsilon;"->"υ","&phi;"->"φ","&chi;"->"χ","&psi;"->"ψ","&omega;"->"ω","&thetasym;"->"ϑ","&upsih;"->"ϒ","&piv;"->"ϖ","&OElig;"->"Œ","&oelig;"->"œ","&Scaron;"->"Š","&scaron;"->"š","&Yuml;"->"Ÿ","&fnof;"->"ƒ","&circ;"->"ˆ","&tilde;"->"˜","&ensp;"->"  ","&emsp;"->" ","&thinsp;"->"  ","&zwnj;"->"‌","&zwj;"->"‍","&lrm;"->"‎","&rlm;"->"‏","&ndash;"->"–","&mdash;"->"—","&lsquo;"->"‘","&rsquo;"->"’","&sbquo;"->"‚","&ldquo;"->"“","&rdquo;"->"”","&bdquo;"->"„","&dagger;"->"†","&Dagger;"->"‡","&bull;"->"•","&hellip;"->"…","&permil;"->"‰","&prime;"->"′","&Prime;"->"″","&lsaquo;"->"‹","&rsaquo;"->"›","&oline;"->"‾","&euro;"->"€","&trade;"->"™","&larr;"->"←","&uarr;"->"↑","&rarr;"->"→","&darr;"->"↓","&harr;"->"↔","&crarr;"->"↵","&lceil;"->"⌈","&rceil;"->"⌉","&lfloor;"->"⌊","&rfloor;"->"⌋","&loz;"->"◊","&spades;"->"♠","&clubs;"->"♣","&hearts;"->"♥","&diams;"->"♦","&frasl;"->"⁄","&weierp;"->"℘","&image;"-> "ℑ","&real;"->"ℜ","&alefsym;"->"ℵ","&lang;"->"⟨","&rang;"->"⟩","&lArr;"->"⇐","&uArr;"->"⇑","&rArr;"->"⇒","&dArr;"->"⇓","&hArr;"->"⇔")
      def replace(a:String,b:String):String = a.replaceAll(b,ent2uni(b))
        ent2uni.keys.foldLeft(t)(replace)
   }

    //"when" variable must be dd-mm-yyyy

def trackChanges(text:String, who:String, what:String, when:String):String={text.replaceAll("</revisionDesc>","</change>--><change when=\""+when +"\" who=\""+ who +"\">"+ when+"</change></revisionDesc>")}

def epiDocTEI(t:String):String = {

   val preheader ="<?xml version=\"1.0\" encoding=\"UTF-8\"?> <?xml-model href=\"http://www.stoa.org/epidoc/schema/latest/tei-epidoc.rng\" schematypens=\"http://relaxng.org/ns/structure/1.0\"?> <TEI xmlns=\"http://www.tei-c.org/ns/1.0\">" 
   return preheader + "<teiHeader" + t.split("<teiHeader")(1).replaceAll("</TEI.2>","</TEI>")
}

//this must be done AFTER fixLanguageId and fix Pb

def fixId:String={return text.replaceAll(" id=\""," xml:id=\"")}

//This needs work to be more general

def fixFunder:String ={
  val Funder = """&fund.*?;""".r
  val funder = Funder.findAllIn(text).mkString
  val fundString = funder.replaceAll("&fund.","").replaceAll(";","")
  return text.replaceAll("<funder n=\"org:AnnCPB\">The Annenberg CPB Project</funder>","<funder n=\"org:"+ fundString+"\">"+ fundString+"</funder>").replaceAll(funder,"")
  }

//The corr/sic problem isn't super common but here's a SAX Parser to fix it anyways

/*<corr sic="bell">bello</corr>

becomes

<choice> <corr> bello</corr><sic>bell</sic></choice>*/

def fixCorrSic = {

  import scala.io.Source
  import scala.xml.pull._
  import java.io._

  val xml = new XMLEventReader(Source.fromFile(filePath))

  var sic:String = ""
  var corr:Boolean = false

  def transform(ev:XMLEvent):String = ev match {

  case EvElemStart(pre,"corr",attrs,scope) => {sic =
      attrs("sic").mkString;s"<choice><corr>"}
      case EvElemEnd(scope,"corr") => {corr = false;
      s"</corr><sic>${sic}</sic></choice>"}
      case EvElemStart(pre,label,attrs,scope) =>s"<${pre}:${label}${attrs}>"
      case EvElemEnd(scope,label) =>  s"</${label}>"
      case EvText(text) => text
      case EvComment(text) => "<!--" + text + "-->"
      case EvEntityRef(entity) => entity
      case EvProcInstr(target,text) => text
      case _ => ""

    }

  val y = xml.toSeq map transform

  val z = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><?xml-model href=\"http://www.stoa.org/epidoc/schema/latest/tei-epidoc.rng\" schematypens=\"http://relaxng.org/ns/structure/1.0\"?><TEI xmlns=\"http://www.tei-c.org/ns/1.0\">" + y.mkString.replaceAll("<null:","<").replaceAll("<TEI>","")

  val newPath = new java.io.File(filePath)
  newPath.mkdirs()
  val wrt = new PrintWriter(new File(filePath))

  wrt.print(z)
  wrt.flush
  wrt.close

}

//III. Demonstration of Use

def fixProblems(example:LegacyPerseusText) = {
    val p = new java.io.File(example.filePath)
    if (p.exists()){
    //this is where the corrections go
    val fixed = example.easyEpidocFixes
    val fullyUni = html2uni(fixed)
    val epiXml = epiDocTEI(fullyUni)
    //FIX THIS WHOLE REVISION DESC TRACKING BUSINESS, AND MAKE SURE XML:XML:LANG STOPS HAPPENING
    val editorialRecord = trackChanges(epiXml, example.who, example.what, example.when)
    //end of corrections
    val wrt =  new PrintWriter(p)
    wrt.print(editorialRecord)
    wrt.flush
    wrt.close
  }else{
    print(example.filePath + " doesn't exist")}} 

val test = new LegacyPerseusText("tlg0007.tlg092.perseus-eng1", "canonical-greekLit/data/tlg0007/tlg092/tlg0007.tlg092.perseus-eng1.xml","Stella Dee","converted to EpiDoc","2015")

//uncomment next line to run
//fixProblems(test)

//IV. A few generally helpful Scala functions

//To get list of all files in directory:

import java.io.File
def recursiveListFiles(f: File): Array[File] = {
  val these = f.listFiles
  these ++ these.filter(_.isDirectory).flatMap(recursiveListFiles)
}

//snippet for running jar files (e.g. for unicode converstion) from Scala code

/*fileList.map { f =>
    if(f.contains("gk.xml")){
    val process: Process = Process("java -jar transformer.jar " + f).run()
    } else{}
}*/

def urn2fPath(urnList:List[String]): List[String] = {
  urnList.map(x=>x.split(":")(2) + "/" +  x.split(":")(3).split("\\.")(0) + "/" +x.split(":")(3).split("\\.")(1) + "/" + x.split(":")(3) + ".xml")

}



