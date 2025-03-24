<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
   <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>

	
	   <!-- 그리드 컬럼안 검색 스크립트 -->
	   <script type="text/javascript">
	   
	   $(document).ready(function() {
		   // AUIGrid 그리드를 생성합니다.
		  createAUIGridSendTarget();
	   });
	   
	   function createAUIGridSendTarget() {
		    var auiGridProps = {
		         editable : false,
		         softRemoveRowMode : false,
		         rowHeight : 30
			};
		    
		   var columnLayout = [
			      {
			         dataField : "phone_no",
			         headerText : "휴대폰번호",
			         width: 100,
			         style : "aui-center",
			         labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return $M.phoneFormat(value); 
					 }
			      },
			      {
				     dataField : "receiver_name",
				     headerText : "이름",
				     width: 100,
				     style : "aui-center"
				  },
			   	  {
			         dataField : "ref_key",
			         headerText : "참조키",
			         style : "aui-center"
			      }
		   ];
			   
		   var sendTargetData = [
			   {"phone_no" : "01066003543", "receiver_name" : "김태훈", "ref_key": "20191105171937231"},
			   {"phone_no" : "01057201540", "receiver_name" : "엄정영", "ref_key": "20191010125342480" },
			   {"phone_no" : "01080002835", "receiver_name" : "장현석", "ref_key": "20190509170457695"},
			   {"phone_no" : "01052637203", "receiver_name" : "박준영", "ref_key": "MB00001097" },
			   {"phone_no" : "01041443806", "receiver_name" : "김태공", "ref_key": "MB00000060" },
			  
		   ]
 
		    auiGridSendTarget = AUIGrid.create("#auiGridSendTarget", columnLayout, auiGridProps);
			AUIGrid.setGridData(auiGridSendTarget, sendTargetData);
	   }

	  // 문자발송
	  function fnSendSms() {
		   var param = {
				   'name' : $M.getValue('name'),
				   'hp_no' : $M.getValue('hp_no'),
				   'sms_send_type_cd' : $M.getValue('sms_send_type_cd'),
				   'req_sendtarger_yn' : $M.getValue('req_sendtarger_yn'),
				   'req_key' : $M.getValue('req_key')
		   	};
	   		openSendSmsPanel($M.toGetParam(param));
	  }
	     
		//문자발송 참조
	  function reqSendTargetList(){		
			
			var parentTargetList = [];
			var tempList = AUIGrid.getGridData(auiGridSendTarget);
			for (var i = 0; i < tempList.length; i++) {
				var obj = new Object();											
				obj['phone_no'] = tempList[i].phone_no;
				obj['receiver_name'] = tempList[i].receiver_name;
				obj['ref_key'] = tempList[i].ref_key;										
				parentTargetList.push(obj);
			}
			alert(JSON.stringify(parentTargetList));
			return parentTargetList;
	  }

   </script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
   <div class="content-wrap">
      <div class="content-box">
      		<!-- 메인 타이틀 -->
			<div class="main-title"></div>
			<!-- /메인 타이틀 -->
            <div class="contents" style="width:100%; float: left;">
   <!-- 기본 -->               
               <table class="table-border">
             		 <h2>문자발송 팝업 파라미터</h2>
   		 			<colgroup>
						<col width="120px">
						<col width="130px">
						<col width="120px">
						<col width="150px">
						<col width="150px">
						<col width="150px">
						<col width="150px">
						<col width="80px">
						<col width="">
					</colgroup>
               		<thead>
               		<th>기능명</th>
               		<th>함수명</th>
               		<th>param1</th>
               		<th>param2</th>
               		<th>param3</th>
               		<th>param4</th>
               		<th>param5</th>
               		<th>기능버튼</th>
               		<th>예시</th>
               		</thead>
                  	<tbody>
                        <tr>
                        <td><label>문자발송</label></td>
                        <td><label>openSendSmsPanel</label></td>
                        <td><input type="text" class="form-control" id="name" name="name" value="" style="width: 90px;" placeholder="이름"></td>
                        <td>
                        	<span style="color:red;">SMS전송타입이<br>고객 OR사원인경우 필수</span>
                        	<input type="text" class="form-control" id="hp_no" name="hp_no" value="" format="phone" style="width: 90px;" placeholder="핸드폰 번호">
                       	</td>
                        <td>	
                        	<select class="form-control" id="sms_send_type_cd" name="sms_send_type_cd">
								<option value="">- SMS전송타입 - </option>
								<c:forEach var="item" items="${codeMap['SMS_SEND_TYPE']}">
									<option value="${item.code_value}">${item.code_name}</option>										
								</c:forEach>
							</select>
						</td>
                        <td>
                         	 발송대상 참조여부 <br>
                         	 (참조시 발송대상 변경 불가)
                       		 <input type="text" class="form-control" id="req_sendtarger_yn" name="req_sendtarger_yn" style="width: 130px;" value="" placeholder="발송대상 참조여부( Y / N )">
                        </td>
                        <td>
                        	참조키<br>
                        	<span style="color:red;">SMS전송타입이<br>
                        	고객 OR사원 인경우 필수</span>
                        	<input type="text" class="form-control" id="req_key" name="req_key" style="width: 130px;" value="" alt="참조키" placeholder="고객번호 OR 사원번호">
                        </td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:fnSendSms();">문자발송</button></td>
                    	<td>
                    		<p>name=장현석&hp_no=01066003545&sms_send_type_cd=3&req_sendtarger_yn=N&req_key='20071217225716887'</p>
                    	</td>
                     </tr>
            
                  </tbody>
               </table>
            </div>
   
      	<div class="contents" style="width:30%; float: left;"> 
 		  	<div class="main-title" >
	         	<h2>그리드(문자발송대상 참조시)</h2>
         	</div>     
         	<div id="auiGridSendTarget" style="width:100%; height:200px;"></div>
      	</div>   
       	<div class="contents" style="width:40%; float: left;"> 	
       	 	<div class="main-title" >
	         	<h2>문자발송참조방법</h2>
         	</div> 
         	<table class="table-border">
         		<tr>
                   	<td>
                   		방식    : &nbsp;<span style="color:red;">함수호출 </span><br>
                   		함수명 : <span style="color:red;">reqSendTargetList()</span><br/><br>
                   		함수정의 <br><br>
                   	    	&emsp;(1)그리드에서 가져오는 경우<br/>
	                   	    &emsp; function <span style="color:red;">reqSendTargetList</span>(){	<br/>		
                	    	&emsp; &emsp;var parentTargetList = [];<br/>
							&emsp; &emsp; var tempList = AUIGrid.getGridData(<span style="color:red;">그리드명</span>);<br/>
							&emsp; &emsp; for (var i = 0; i < tempList.length; i++) {<br/>
							&emsp; &emsp;&emsp; var obj = new Object();<br/>											
							&emsp; &emsp;&emsp;&emsp; obj['<span style="color:red;">phone_no</span>'] = <span style="color:red;">휴대폰번호</span>;<br/>
							&emsp; &emsp;&emsp;&emsp; obj['<span style="color:red;">receiver_name</span>'] = <span style="color:red;">이름</span>;<br/>
							&emsp; &emsp;&emsp;&emsp; obj['<span style="color:red;">ref_key</span>'] = <span style="color:red;">참조키</span> ;<br/>											
							&emsp; &emsp;&emsp;&emsp; parentTargetList.push(obj);<br/>
							&emsp; &emsp; }<br/>
						 	&emsp; &emsp;&emsp;&emsp; return parentTargetList;<br/>
							&emsp; &emsp; }<br/><br/>
							&emsp;(2)그리드가 아닌경우<br/>
						&emsp; <span style="color:red;">json 배열</span>형식으로 호출 
                   	</td>
				</tr>  
         	</table>                   
       	</div>
       	<div class="contents" style="width:30%; float: left;"> 	
       	 	<div class="main-title" >
	         	<h2>문자발송참조 칼럼</h2>
         	</div> 
         	<table class="table-border">
         		<tr>
					<td>
					&emsp; 1.<span style="color:red;">phone_no</span> ( 휴대폰번호)<br/>
					&emsp; 2.<span style="color:red;">receiver_name</span>(이름)<br/>
					&emsp; 3.<span style="color:red;">ref_key</span> ( 참조키 - 고객번호 OR직원번호 , 둘다아니면 기본 공백)
                  	</td>
				</tr>  
         	</table>                   
         </div>       
      </div>
   </div>
<!-- /contents 전체 영역 -->
</form>
</body>
</html>