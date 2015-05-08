/**
  Salesforce lib got type mapper error for Coverage generated class, So we need a class to parse a raw SOAP xml from tooling api.
  
  You may remove this and replace after salesforce fixed the lib issus. 
  However, the recent release api version 33 after test still show that this issue still unresolved.
  
 **/
public class Global_Test_QueryProcessor 
{       
    private String sessionId;
    private String url;
    
    public Global_Test_QueryProcessor(String sessionId, String url)
    {
        this.sessionId = sessionId;
        this.url = url;
    }
    
    public List<Global_Test_Record> query(String query)
    {       
        String request = getRequestXML(query);
    
        HttpResponse res = post(request);
    
        return toResult(res);
    }
    
    public List<Global_Test_QueryProcessor.ApexClassOrTrigger> queryClass(String query)
    {       
        String request = getRequestXML(query);
    
        HttpResponse res = post(request);
    
        return toClass(res);
    }

    private String getRequestXML(String query)
    {
        String xml = 
        
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:tooling.soap.sforce.com">' +
            '   <soapenv:Header>' +
            '      <urn:SessionHeader>' + 
            '        <urn:sessionId>' + this.sessionId + '</urn:sessionId>' +
            '      </urn:SessionHeader>' +
            '   </soapenv:Header>' +
            '   <soapenv:Body>' +
            '      <urn:query>' +
            '         <urn:queryString>' + query + '</urn:queryString>' +
            '      </urn:query>' +
            '   </soapenv:Body>' +
            '</soapenv:Envelope>';
        
        return xml;
    }
    
    private HttpResponse post(String body)
    {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('SOAPAction', '1.0');
        req.setHeader('Content-Type', 'text/xml');
        req.setEndpoint(this.url);
        req.setMethod('POST');
        req.setBody(body);
        req.setTimeout(30000); 
        
        HttpResponse res = http.send(req);

        return res;
    }
    
    
    public List<Global_Test_Record> toResult(HttpResponse res)
    {
        List<Global_Test_Record> recordList = new List<Global_Test_Record>();

        Xmlstreamreader reader = res.getXmlStreamReader();
        
        Global_Test_Record records = null;
        
        while(reader.hasNext())
        {
            if(reader.getEventType() == XmlTag.START_ELEMENT)
            {
                String name = reader.getLocalName();
               
                if(name.equals('records'))
                {
                   records = new Global_Test_Record();                                       
                }
                
                if(name.equals('ApexClassOrTriggerId'))
                {
                    String val = getElementText(reader);
                                    
                    records.setApexClassOrTriggerId(val);                                        
                }
                
                if(name.equals('ApexTestClassId'))
                {
                    String val = getElementText(reader);
                                    
                    records.setApexTestClassId(val);                                         
                }
                
                if(name.equals('NumLinesCovered'))
                {
                    String val = getElementText(reader);
               
                    Integer covered = Integer.valueOf(val);
                    
                    records.setNumLinesCovered(covered);                               
                }
                
                if(name.equals('NumLinesUncovered'))
                {
                    String val = getElementText(reader);
               
                    integer covered = Integer.valueOf(val);
                    
                    records.setNumLinesUncovered(covered);                               
                }
                
                if(name.equals('coveredLines'))
                {
                    String val = getElementText(reader);
              
                    integer covered = Integer.valueOf(val);
                    
                    records.addCoveredLines(covered);                               
                }
                
                if(name.equals('uncoveredLines'))
                {
                    String val = getElementText(reader);
                
                    integer uncovered = Integer.valueOf(val);
                    
                    records.addUncoveredLines(uncovered);   
                    
                }
                
                if(name.equals('TestMethodName'))
                {
                    String val = getElementText(reader);

                    records.setTestMethodName(val);
                }
                                        
            }
            
            if(reader.getEventType() == XmlTag.END_ELEMENT)
            {
                String name = reader.getLocalName();
                
                if(name.equals('records'))
                {                                               
                    recordList.add(records);
            
                    records = null;                                      
                }              
            }
            
            reader.next();
            
        }
        
        return recordList;  
    }
    
    private String getElementText(XMLStreamReader reader)
    {       
        String text = '';
        
        while(reader.hasNext())
        {
            if(reader.getEventType() == XmlTag.END_ELEMENT)
            {   
                break;
            }
            else if(reader.getEventType() == XmlTag.CHARACTERS)
            {               
                text += reader.getText();
            }
                        
            reader.next();
        }

        return text;
    }
    
    
    public List<ApexClassOrTrigger> toClass(HttpResponse res)
    {
        List<ApexClassOrTrigger> recordList = new List<ApexClassOrTrigger>();
 
        Xmlstreamreader reader = res.getXmlStreamReader();
        
        ApexClassOrTrigger clazz = null;
        
        boolean enterRecord = false;
                
        while(reader.hasNext())
        {
            if(reader.getEventType() == XmlTag.START_ELEMENT)
            {
                String name = reader.getLocalName();
     
                if(name.equals('records'))
                {
                   clazz = new ApexClassOrTrigger();
                   
                   enterRecord = true;
                }
               
                if(name.equals('Id'))
                {
                    String val = getElementText(reader);
                    clazz.id = val;          
                }
                
                if(name.equals('Name'))
                {
                    String val = getElementText(reader);
                    clazz.name = val;
                }
                
                if(enterRecord) {
                
                    if(name.equals('Body'))
                    {
                        String val = getElementText(reader);
                        clazz.body = val;
                    }
                }
                
            }
            
            if(reader.getEventType() == XmlTag.END_ELEMENT)
            {
                String name = reader.getLocalName();
                
                if(name.equals('records'))
                {                                               
                    recordList.add(clazz);
                    
                    clazz = null;
                    
                    enterRecord = false;
                }              
            }
            
            reader.next();
        }
        
        return recordList;  
    }
    
    public class ApexClassOrTrigger
    {
        public String id;
        public String name;
        public String body;
    }
    

}