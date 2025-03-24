<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
   <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
   
   	<!--  Barcode Scanner JS / auiHeader.jsp 넣을 예정-->
	<script type="text/javascript" src="/static/js/jquery.scannerdetection.js"></script>
</head>

<script>
$(document).scannerDetection({ 
    timeBeforeScanTest: 200, // wait for the next character for upto 200ms 
    startChar: [120], // Prefix character for the cabled scanner (OPL6845R) 
    endChar: [13], // be sure the scan is complete if key 13 (enter) is detected 
    avgTimeByChar: 40, // it's not a barcode if a character takes longer than 40ms 
    minLength :6,
    onComplete: function(barcode, qty){
        alert(barcode); // 바코드 출력 
    }
 /*    
$(window).scannerDetection();
$(window).bind('scannerDetectionComplete',function(e,data){
        alert('complete '+data.string);
    })
    .bind('scannerDetectionError',function(e,data){
        console.log('detection error '+data.string);
    })
    .bind('scannerDetectionReceive',function(e,data){
        console.log(data);
    })

$(window).scannerDetection('success');

 */
}); 

$(document).ready(function(){
	$("#dispatchEvent").click(function(){
		var barcode = $("#varCode").val().split('');
		var i = 0;
		console.log(barcode);
		
		var i = -1;
		var timer = setInterval(function(){
			var event = document.createEvent("Events");
			event.initEvent('keydown', true, true);
			
			if(i == -1){
				//스캐너 시작문자
				event.keyCode = 120;
				document.dispatchEvent(event);
				i++
			}else if(i == barcode.length){
				clearInterval(timer);
				//스캐너 종료문자
				event.keyCode = 13;
				document.dispatchEvent(event);
			}else{
				event.keyCode = barcode[i].charCodeAt(0);
				document.dispatchEvent(event);
				i++;
			}
			console.log(event.keyCode);
		}, 30);
	});
});
</script>
<body>
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
    	<div class="content-box">
	   		<!-- 메인 타이틀 -->
	        <div class="main-title" style="width:900px;">
            	<h2>barcode</h2>
         	</div>
  	 		<!-- /메인 타이틀 -->
         	<div class="contents">
         		Scanner Event : <input type="text" id="varCode" value="1234567"> <input type="button" id="dispatchEvent" value="이벤트발생"><br/><br/>
		 		Enter/Scan Barcode : <input type="text" id="txtCode" class="barcodeinput"/>
				<!-- <input type="button" value="OK" class="nextcontrol"/> -->
				<h3 id="msg"/>
         </div>
      </div>
   </div>
<!-- /contents 전체 영역 -->
</form>
</body>
</html>
