/**
    Global_Test_CodeCoverageReader using tooling api for retrieve apex class/trigger code coverage and show out in percent.
    It filter the file name contains "Test" and "test" (case sensitive)
    
    author : kiwi

**/
public class Global_Test_CodeCoverageReader
{
    private String sessionId;
    private String endpoint;
    private Global_Test_QueryProcessor qp; 
    
    public Global_Test_CodeCoverageReader(String sessionId, String endpoint)
    {
        this.sessionId = sessionId;
        this.endpoint = endpoint + '/services/Soap/T/32.0';
        
        qp = new Global_Test_QueryProcessor(sessionId, this.endpoint);
    }
    
    public List<TestResult> getCodeCoverage(String type, String filter)
    {                   
        List<TypeInfo> typeList;
        
        if(type.equals('ApexClass'))
            typeList = getClazzList(filter, 'ApexClass');
        else
            typeList = getClazzList(filter, 'ApexTrigger');
            
        if(typeList.isEmpty())
            return new List<TestResult>();
            
        String queryId = createQueryIds(typeList);  
        
        String query = 'SELECT ApexTestClassId, ApexClassorTriggerId, TestMethodName, NumLinesCovered, NumLinesUncovered, Coverage FROM ApexCodeCoverage WHERE ApexClassOrTriggerId in (' + queryId + ')';
        List<Global_Test_Record> record = qp.query(query);
        
        for (Global_Test_Record rec : record) {
            for (TypeInfo kv : typeList) 
            {           
                String id = kv.getId();
                
                if(id.equals(rec.getApexClassOrTriggerId()))
                {
                    rec.setApexClassName(kv.getName());
                }
            }
        }
        
        return processResult(record, typeList);
    }
    
    private List<TestResult> processResult(List<Global_Test_Record> recordList, List<TypeInfo> clazzList) 
    {
        List<TestResult> result = new list<TestResult>();
        
        List<LineCoverage> codeCoverage = getCoverage(recordList);
        
        for (TypeInfo  kv : clazzList) 
        {
            String id = kv.getId();
            String name = kv.getName();
            String type = kv.getType();
            
            Set<Integer> allcover = new set<Integer>();         
            Set<Integer> alluncover = new set<Integer>();
            
            for (Global_Test_Record rec : recordList) 
            {       
                if(id.equals(rec.getApexClassOrTriggerId())) {
                
                    Set<Integer> cover = rec.getCoverage().getCoveredLines();
                    allcover.addAll(cover); 
                    
                    Set<Integer> uncover = rec.getCoverage().getUncoveredLines();
                    alluncover.addAll(uncover); 
                }
            }
            
            alluncover.removeAll(allcover);
                        
            double percent = 0;
            
            if(!(alluncover.isEmpty() && allcover.isEmpty()))
                percent = ( allcover.size() / ((double)allcover.size() + (double)alluncover.size()) ) * 100;
                
            LineCoverage lineCoverage = null;
            
            for (LineCoverage lc : codeCoverage) {
                if(id.equals(lc.getClassName()))
                {
                    lineCoverage = lc;
                }
            }
            
            
            result.add(new TestResult(id, name, percent, type, lineCoverage));
        }
        
        result.sort();
        
        return result;
    }
    
    private String createQueryIds(List<TypeInfo> clazzList) 
    {
    	if(clazzList.isEmpty())
    		return '';
    	
        String allId = '';

        for (TypeInfo kv : clazzList) {
            allId += '\'';
            allId += kv.getId();
            allId += '\'';
            allId += ',';
        }       

        allId = allId.substring(0, allId.length()-1);
        
        System.debug('all id -> ' + allId);
        
        return allId;
    }
    
    private List<TypeInfo> getClazzList(String filter, String type)
    {
        List<TypeInfo> clazzList = new List<TypeInfo>();
    
        String soql = 'SELECT id, name, ApiVersion, Status FROM ' + type + ' where name like \'' + filter + '%\' ';
        List<Global_Test_QueryProcessor.ApexClassOrTrigger> result = qp.queryClass(soql);
        
        for (Global_Test_QueryProcessor.ApexClassOrTrigger clazz : result) {
                    
            String id = clazz.id;
            String name = clazz.Name;
            
            if(name.contains('Global_Test')) {             
                clazzList.add(new TypeInfo(id, name, type));
            }            
                        
            if(!(name.contains('Test') || name.contains('test'))) {             
                clazzList.add(new TypeInfo(id, name, type));
            }
        }
        
        return clazzList;
    }
    
    public String getCode(String id)
    {
        String soql = 'SELECT id, Body, name, ApiVersion, Status FROM ApexClass where id = \'' + id + '\'';
        List<Global_Test_QueryProcessor.ApexClassOrTrigger> result = qp.queryClass(soql);
            
        Global_Test_QueryProcessor.ApexClassOrTrigger clazz = result.get(0);
        
        String body = clazz.body;
    
        return body;
    }
    
    public List<LineCoverage> getCoverage(List<Global_Test_Record> records)
    {       
        List<LineCoverage> coverage = new list<LineCoverage>();
        Set<String> ids = new set<String>();
        
        for (Global_Test_Record rec : records) 
        {           
            LineCoverage cov = new LineCoverage();
            cov.setClassName(rec.getApexClassOrTriggerId());
                
            if(!ids.contains(rec.getApexClassOrTriggerId())) {
                for (Global_Test_Record com : records) {
                    
                    if(rec.getApexClassOrTriggerId().equals(com.getApexClassOrTriggerId()))
                    {
                        Global_Test_Record.Coverage c = com.getCoverage();
                        
                        for (integer lin : c.getCoveredLines()) {
                            cov.addCoverage(lin);
                        }
                        
                        for (integer lin : c.getUncoveredLines()) {
                            cov.addUncoverage(lin);
                        }
                        
                    }               
                }               
                
                cov.getUncoverage().removeAll(cov.getCoverage());
                
                coverage.add(cov);
            }
            
            ids.add(rec.getApexClassOrTriggerId());
        }       
        
        return coverage;
    }
    
    public class LineCoverage
    {
        private String className;
        private Set<Integer> coverage = new set<Integer>();
        private Set<Integer> uncoverage = new set<Integer>();
        
        public String getClassName() {
            return className;
        }
        
        public void setClassName(String className) {
            this.className = className;
        }
        
        public Set<Integer> getCoverage() {
            return coverage;
        }
        
        public void addCoverage(integer coverage) {
            this.coverage.add(coverage);
        }
        
        public Set<Integer> getUncoverage() {
            return uncoverage;
        }
        
        public String getCoverageString() 
        {
            return toString(coverage);
        }
        
        public String getUncoverageString() 
        {
            return toString(uncoverage);
        }
        
        public String toString(Set<Integer> lines) 
        {
            if(lines.isEmpty())
                return '';
            
            String buf =  '';
            
            for (Integer line : lines) {
                buf += line;
                buf +=',';
            }
            
            buf = buf.substring(0, buf.length() - 1);
            
            return buf;
        }
        
        
        public void addUncoverage(integer uncoverage) {
            this.uncoverage.add(uncoverage);
        }

        public override String toString() {
            return 'LineCoverage [className=' + className + ', coverage='
                    + coverage + ', uncoverage=' + uncoverage + ']';
        }
        
    }
   
     
    private class TypeInfo
    {
        private final String id;
        private final String name;
        private final String type;
        
        public TypeInfo(String id, String name, String type)
        {
            this.id = id;
            this.name = name;
            this.type = type;
        }

        public String getId() {
            return id;
        }

        public String getName() {
            return name;
        }

        public String getType() {
            return type;
        }       
    }
    
    public class TestResult implements Comparable
    {
        private final String id;
        private final String name;
        private final String status;
        private final double percent;
        private final String type;
        private final LineCoverage coverage;
        
        public TestResult(String id, String name, double percent, String type, LineCoverage coverage) 
        {
            this.id = id;
            this.name = name;
            this.percent = percent;
            this.type = type;
            this.coverage = coverage;
        }

        public String getId() {
            return id;
        }

        public String getName() {
            return name;
        }
        
        public String getStatus() {
            
            if(percent < 75)
                return 'danger';
              
            return 'success';
        }

        public double getPercent() {
            return percent;
        }
        
        public LineCoverage getCoverage() {
            return coverage;
        }
        
        public Integer compareTo(Object obj)
        {
            TestResult c = (TestResult)obj;
            
            if(c.name > name)
                return -1;
                
            if(c.name < name)
                return 1;
                
            return 0;
        }

        public override String toString() {
            return 'TestResult [id=' + id + ', name=' + name + ', percent='
                    + percent + ', type=' + type + ']';
        }
    }
   
}