/**
    Global_Test_Record is a Result of code coverage.
    
    author : kiwi

**/
public class Global_Test_Record 
{
    private String ApexClassName;
    
    private String ApexClassOrTriggerId;
    private String apexTestClassId;
    private Coverage coverage = new Coverage();
    private String TestMethodName;
    private Integer NumLinesUncovered;
    private Integer NumLinesCovered;
    
    
    public String getApexTestClassId() {
        return apexTestClassId;
    }


    public void setApexTestClassId(String apexTestClassId) {
        this.apexTestClassId = apexTestClassId;
    }

    public Coverage getCoverage() {
        return coverage;
    }


    public String getTestMethodName() {
        return TestMethodName;
    }


    public void setTestMethodName(String testMethodName) {
        this.TestMethodName = testMethodName;
    }


    public Integer getNumLinesUncovered() {
        return NumLinesUncovered;
    }


    public void setNumLinesUncovered(Integer numLinesUncovered) {
        this.NumLinesUncovered = numLinesUncovered;
    }


    public Integer getNumLinesCovered() {
        return NumLinesCovered;
    }


    public void setNumLinesCovered(Integer numLinesCovered) {
        this.NumLinesCovered = numLinesCovered;
    }


    public override String toString() {
        return 'Records [apexTestClassId=' + apexTestClassId + ', coverage='
                + coverage + ', TestMethodName=' + TestMethodName
                + ', NumLinesUncovered=' + NumLinesUncovered
                + ', NumLinesCovered=' + NumLinesCovered + ']';
    }
    
    public void addCoveredLines(Integer covered)
    {
        this.coverage.coveredLines.add(covered);
    }
    
    public void addUncoveredLines(Integer uncovered)
    {
        this.coverage.uncoveredLines.add(uncovered);
    }
    
    public double getCodeCoveragePercent()
    {
        double percent = ( (double)coverage.coveredLines.size() / ((double)coverage.coveredLines.size() + (double)coverage.uncoveredLines.size())) * 100;
        
        return percent;
    }

    public String getApexClassOrTriggerId() {
        return ApexClassOrTriggerId;
    }


    public void setApexClassOrTriggerId(String apexClassOrTriggerId) {
        this.ApexClassOrTriggerId = apexClassOrTriggerId;
    }

    public String getApexClassName() {
        return ApexClassName;
    }


    public void setApexClassName(String apexClassName) {
        this.ApexClassName = apexClassName;
    }

    public class Coverage 
    {
        private Set<Integer> coveredLines = new set<Integer>();
        private Set<Integer> uncoveredLines = new set<Integer>();
        
        public Set<Integer> getCoveredLines() {
            return coveredLines;
        }
    
        public Set<Integer> getUncoveredLines() {
            return uncoveredLines;
        }

        public Override String toString() {
            return 'Coverage [coveredLines=' + coveredLines
                    + ', uncoveredLines=' + uncoveredLines + ']';
        }
                
        
    }

}