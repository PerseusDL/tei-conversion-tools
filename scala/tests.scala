import java.io._
import scala.xml._
import scala.util.matching.Regex

//IMPROVE ERROR HANDLING EVERYWHERE, ESP. IN XML CREATION!

class PerseusText(
	val urn: String,
	val filePath: String) {

	def xmlText:scala.xml.Elem = {

		val plnText = scala.io.Source.fromFile(filePath).mkString.replaceAll("TEI.2", "TEI")

	if ("&.*?;".r.findFirstIn(plnText).isEmpty) {

		return XML.loadString(plnText)

	} else {
		//dealing with referenced but undeclared entities, just commenting out for now, but this is lazy and they should be fixed better (but maybe in the next EpiDoc process?)
		return XML.loadString("&.*?;".r.replaceAllIn(plnText, "<!--" + "$0" + "-->"))
		//change this to log : ("This text has the following problematic undeclared entities:" + "&.*?;".r.findAllIn(plnText).toList.distinct) //we'll need to go back and deal with them later,change the printing to logging
	}
	//add error handling to the above, in case the XML still isnt valid 
	}

	def citeSchema: scala.collection.immutable.Seq[scala.xml.NodeSeq] ={

		(xmlText \\ "refsDecl" \ "state").map(x=> x \ "@unit")

	}

	def refs: List[String] ={

		citeSchema.toList.map(x=>x.toString)
	}

	//Tests and Fixes

	//checking and fixing if lines are numbered every 5-do anytime

	def lineNumFix:Any ={
		//check if all lines have numbers, if not, number the lines, port fix-misc.pl
	}

	def lineNumTest:Any = {

		if (citeSchema.map(x=>x.mkString).contains("line")){ 
			print("Lines required re-numbering")
			return lineNumFix
		
	} else{
			print("No lines requiring re-numbering")
			
	}
	}

	//checking and fixing if divs are numbered, e.g. div1, div2, div3 instead of just div

	def numDivFix:Any = {
		"div\\d".r.replaceAllIn(xmlText.mkString, "div")
	}

	def numDivTest:Any = {

		if ("div\\d".r.findFirstIn(xmlText.mkString).mkString.contains("div")) {

		print("Numbered divs changed to unnumbered divs")
		return numDivFix
		} else{

			print("No numbered divs found")
		}
	}

	//checking and fixing for problematic milestones, changing them to <div>s

	def probMilestoneFix:Any ={
		//port milestones_to_divs.xsl
	}

	def probMilestoneTest: Any = {

		if(refs.map(x=> (xmlText \\ "milestone").map(m=> m.mkString).filter(m => m.contains(x)).toList).flatten.nonEmpty) {

			print("Problematic milestones exist")
			return probMilestoneFix
	} else{
		print("No problematic milestones found")
	}

	//TO-DO: speakers to said (port speakerstosaid.xsl), splitting multiple works from a single file, unicode conversions, q tags that get split, <sp> and <said> tags that get split
}

}


val mTest = new PerseusText("tlg0032.tlg011.perseus-grc1", "milestoneTest.xml")
val nTest = new PerseusText("tlg0001.tlg001.perseus-grc1", "linerenumtest.xml")

//mTest.probMilestoneTest should find problems, but the other tests should not
//nTest.numDivTest should find and fix problems, nTest.lineNumTest should find problems,  nTest.probMilestonTest should find NO problems




