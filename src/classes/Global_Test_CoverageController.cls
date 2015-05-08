/**
    Global_Test_CoverageController code coverage for particular apex class/trigger.
    
    author : kiwi

**/
public class Global_Test_CoverageController {

    public String name { get; set; }
    public String code { get; set; }
    public String uncovered { get; set; }
    public String covered { get; set; }    
    public String type { get;set;}
    public String id { get;set;} 
    public Long use { get;set;}
    
    public List<Global_Test_CodeCoverageReader.TestResult> result { get;set;}
        
    public PageReference getCoverage()
    {
        id = ApexPages.currentPage().getParameters().get('id');
        name = ApexPages.currentPage().getParameters().get('name');
        type = ApexPages.currentPage().getParameters().get('type');
        covered = ApexPages.currentPage().getParameters().get('covered');
        uncovered = ApexPages.currentPage().getParameters().get('uncovered');
        
        String domain = URL.getSalesforceBaseUrl().toExternalForm();
        
        Long start = system.currentTimeMillis();
        
        Global_Test_CodeCoverageReader reader = new Global_Test_CodeCoverageReader(UserInfo.getSessionId(), domain);
        
        if(type.equals('ApexClass'))
        {
            code = reader.getCode(id);         
        }
        else
        {
            code = reader.getCode(id);     
        }
        
        code = EncodingUtil.base64Encode(Blob.valueOf(code));
        
        Long en = System.currentTimeMillis();
        
        use = en - start;
   
        return null;
    }
     
}