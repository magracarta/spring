<%@ page contentType="text/html;charset=utf-8" language="java"%>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 전자세금계산서 조회 - (주)YK건기
-- 작성자 : 박예진
-- 최초 작성일 : 2020-09-03 18:20:36
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<%-- <c:import url="/inc/htmlHead.jsp" /> --%>
	<script type="text/javascript">
	
	$(document).ready(function() {
	});
	
	function easySearch_onClick() {
		document.getElementById("fld1").value = loginForm.issueNum[0].value;				
		document.getElementById("fld2").value = loginForm.issueNum[1].value;
		document.getElementById("fld3").value = loginForm.issueNum[2].value;
		document.rdForm.target = "_blank";
		document.rdForm.submit();
// 		var param = {
// 				"fld1" : $M.getValue("fld1"), 
// 				"fld2" : $M.getValue("fld2"),
// 				"fld3" : $M.getValue("fld3")
// 		}
// 		var popupOption = "";
// 		$M.goNextPage('/tax/tax.do', $M.toGetParam(param), {popupStatus : popupOption});
	}
	
	function easySearch_onClick2() {
		document.loginForm.submit();
// 		var param = {
// 			"breg_no" : $M.getValue("breg_no")	
// 		};
// 		$M.goNextPage("/tax/taxList.do", $M.toGetParam(param), {method : 'POST'});
	}
	
	function easySearch_onClick3(p1, p2, p3){
		document.getElementById("fld1").value = p1;				
		document.getElementById("fld2").value = p2;
		document.getElementById("fld3").value = p3;
		document.rdForm.target = "_blank";
		document.rdForm.submit();
	}

	function easySearch_onClick(){
		document.getElementById("fld1").value = loginForm.issueNum[0].value;				
		document.getElementById("fld2").value = loginForm.issueNum[1].value;
		document.getElementById("fld3").value = loginForm.issueNum[2].value;
		document.rdForm.target = "_blank";
		document.rdForm.submit();
	}

	function btnSearch_onClick(str1,str2,str3){
		document.getElementById("fld1").value = str1;
		document.getElementById("fld2").value = str2;
		document.getElementById("fld3").value = str3;

		document.rdForm.submit();
	}

	function onFocusPwDummu(){
		document.getElementById('loginPwDummy').style.display = "none";
		document.getElementById('loginPw').style.display = "block";

		document.loginForm.loginPw.focus();
		
	}

	function onBlurPw(){
	    if(document.getElementById("loginPw").value.length == 0){
			document.getElementById('loginPw').style.display = "none";
			document.getElementById('loginPwDummy').style.display = "block";
		}
		
	}

	function onFocusId(obj){
		if(document.getElementById('loginId').value=='아이디'){
			document.getElementById('loginId').value='';
			document.getElementById('loginId').style.color = "#000000";

		}		
	}

	function onBlurId(){		
		if(document.getElementById('loginId').value.length==0){
			document.getElementById('loginId').style.color = "#a4a4a4";
			document.getElementById('loginId').value='아이디';
		}

	}

	function monthChange(){
		var calYear = document.getElementById("yearSelect").value;
		var calMonth = document.getElementById("monthSelect").value;

		var monthDays = new Array(31,28,31,30,31,30,31,31,30,31,30,31);

		if(((calYear%4 == 0) && (calYear%100 != 0)) || (calYear%400 == 0)) monthDays[1] = 29;

		var innerHtml = "<SELECT id='daySelect' setDisplayCount='10'>\n";

		var j = "";
		for(var i = 1; i <= monthDays[calMonth-1]; i++){
			if(i < 10) j = "0" + i;
			else j = i;

			innerHtml += "	<option value="+j+">"+j+"</option>\n";
		}

		innerHtml += "</SELECT>\n";

		document.getElementById("dayHtml").innerHTML = innerHtml;
	}

	function monthToChange(){
		var calYear = document.getElementById("yearToSelect").value;
		var calMonth = document.getElementById("monthToSelect").value;

		var monthDays = new Array(31,28,31,30,31,30,31,31,30,31,30,31);

		if(((calYear%4 == 0) && (calYear%100 != 0)) || (calYear%400 == 0)) monthDays[1] = 29;

		var innerHtml = "<SELECT id='dayToSelect' setDisplayCount='10'>\n";

		var j = "";
		for(var i = 1; i <= monthDays[calMonth-1]; i++){
			if(i < 10) j = "0" + i;
			else j = i;

			innerHtml += "	<option value="+j+">"+j+"</option>\n";
		}

		innerHtml += "</SELECT>\n";

		document.getElementById("dayToHtml").innerHTML = innerHtml;
	}

	function selectSearch() {

	    if (''.length > 3) {
			var yearFrom = document.getElementById("yearSelect").value;
			var yearTo = document.getElementById("yearToSelect").value;
			var monFrom = document.getElementById("monthSelect").value;
			var monTo = document.getElementById("monthToSelect").value;
			var dayFrom = document.getElementById("daySelect").value;
			var dayTo = document.getElementById("dayToSelect").value;

			var from = "";
			var to = "";

			from = from + yearFrom + monFrom + dayFrom;
			to = to + yearTo + monTo + dayTo;

			if(from > to){
				alert("시작날짜가 종료날짜보다 클 수 없습니다.");
			} else if(yearFrom != yearTo){
				alert("검색 년도는 같아야 합니다.");
			} else {
				searchForm.fromYear.value = document.getElementById("yearSelect").value;
				searchForm.fromMonth.value = document.getElementById("monthSelect").value;
				searchForm.fromDay.value = document.getElementById("daySelect").value;

				searchForm.toYear.value = document.getElementById("yearToSelect").value;
				searchForm.toMonth.value = document.getElementById("monthToSelect").value;
				searchForm.toDay.value = document.getElementById("dayToSelect").value;

				searchForm.submit();
			}
		} else {
			alert("로그인 후 사용하세요.");
		}
	}

	function form_onSubmit() {
		loginForm.submit();
	}

	function modifyPersonal() {
		window.open("modifyInfo.asp", "", "menubar=no, toolbar=no, location=no, status=no, width=400, height=500");
	}

	function logout(){
		logoutForm.submit();
	}
	
	</script>
</head>
 <style>

/* 	.jui { */
/* 	    font-family: '나눔고딕',Nanum Gothic,'굴림',gulim,'돋움',dotum,Tahoma,sans-serif; */
/* 	    font-size: 12px; */
/* 	    color: #555; */
/* 	    text-align: justify; */
/* 	    line-height: 1.5em; */
/* 	    background-color : #fff; */
/* 	} */
	.jui {
		background-color : #fff;
	}
	.opt_search{width:100%;height:75px;background:url(/img/sub/se_top_bg.gif) repeat-x top;border:1px solid #a2b7ca;margin-top:10px}
	.opt_search th, .opt_search td{background:none;height:20px;padding:7px;border-bottom:1px solid #d5d5d5;}
	.opt_search td.bb {border-bottom:none;vertical-align:middle}
	.opt_search th.bb {border-bottom:none;vertical-align:middle}
	.opt_search th{text-align:center;border-right:1px solid #d5d5d5;}
	.opt_search td{}
	.opt_search td.center{text-align:center;}
	.opt_search input,select,textarea {font-size:12px;height:18px;line-height:140%;border:1px solid #e2e2e2;background: #fff;cursor:text;}
	.opt_search input.none {border:none}
	.opt_search img {vertical-align:middle}
	
	.opt{width:100%;padding-bottom:15px;margin-top:10px}
	.opt th, .opt td{border:1px solid #d5d5d5;background:none;height:20px;padding:5px;}
	.opt td.bbnone {border-top:none}
	.opt th{background-color:#f5f5f5;text-align:center}
	.opt td{}
	.opt td.center{text-align:center;}
	.opt input,select {border:1px solid #707070;height:18px}
	.opt input.none {border:none}
	
	.jui .btn-black{background-color:#5d5d5d;background-image:-moz-linear-gradient(top,#5d5d5d 0,#2d2d2d 50%,#000 50%,#3f3f3f 100%);background-image:linear-gradient(top,#5d5d5d 0,#2d2d2d 50%,#000 50%,#3f3f3f 100%);background-image:-webkit-linear-gradient(top,#5d5d5d 0,#2d2d2d 50%,#000 50%,#3f3f3f 100%);background-image:-o-linear-gradient(top,#5d5d5d 0,#2d2d2d 50%,#000 50%,#3f3f3f 100%);background-image:-ms-linear-gradient(top,#5d5d5d 0,#2d2d2d 50%,#000 50%,#3f3f3f 100%);border:1px solid #000;color:#fff};




</style>
<body class="jui" > 
<form name="loginForm" id="loginForm" method="post" action="/tax/taxList.do">
	<div id="loginArea">
		<table id="top" style="width:100%;">    
		    <tr>
				<td align="left">
				    &nbsp;
				</td>
				<td width="20%" align="center">
				<img src='/static/img/login-logo.png'>
				</td>
				<td width="70%" align="right">
					<table class="opt_search">
						<tr>
							<td style="font-size:100%;"><font color="#202020">발급번호 : </font></td>
							<td style="font-size:80%;">
								<input type="text" name= "issueNum" id="issueNum1" value="" style="width:65px;border-style:groove;ime-mode:none" maxLength=8 /> -
								<input type="text" name= "issueNum" id="issueNum2" value="" style="width:40px;border-style:groove;ime-mode:none" maxLength=4 /> -
								<input type="text" name= "issueNum" id="issueNum3" value="" style="width:25px;border-style:groove;ime-mode:none" maxLength=2 />
							</td>
							<td>
								<a class="btn btn-black" href="javascript:void easySearch_onClick();" >간편조회</a>
							</td>
							<td style="width:100px;">&nbsp;</td>
							<td style="font-size:100%;"><font color="#202020">사업자번호 : </font></td>
							<td style="font-size:80%;"><input type="text" name="regNo" id="regNo" value="${breg_no}" style="width:150px;border-style:groove;ime-mode:none" maxLength="10" /></td>
							<td>
								<a class="btn btn-black" href="javascript:void easySearch_onClick2();" >일괄조회</a>
							</td>
						</tr>
					</table>
				</td>
			</tr>		
		</table>
	</div>
</form>
<c:choose>
	<c:when test="${ not empty list }">
	<table style="width:100%;" class="opt">
		<tr>
			<th>발급번호</th>
			<th>상호</th>
			<th>대표자</th>
			<th>업태</th>
			<th>업종</th>
			<th>주소</th>
			<th>비고</th>
		</tr>
	<c:forEach var="item" items="${list}">
		<tr>
			<td align="center"><a href="javascript:easySearch_onClick3('${ item.taxbill_dt }', '${ item.taxbill_no }', '${ item.taxbill_control_no }');">${ item.taxbill_dt } - ${ item.taxbill_no } - ${ item.taxbill_control_no }</a></td>
			<td>${ item.breg_name }</td>
			<td>${ item.breg_rep_name }</td>
			<td>${ item.breg_cor_type }</td>
			<td>${ item.breg_cor_part }</td>
			<td>${ item.biz_addr1 }</td>
			<td>${ item.desc_text }</td>
		</tr>
	</c:forEach>
	</table>
	</c:when>
	<c:otherwise>
 <table width="100%">
     <tr>
	     <td style='background-color:white;border-style:solid;border-top-color:#A8A8A8;border-bottom-color:#FFFFFF;border-left-color:#FFFFFF;border-right-color:#FFFFFF;border-width:2px; margin:1px;padding:2 0 0 0; border-collapse:1px; font-size:80%'>&nbsp;
		 </td>
	</tr>
 </table>
	</c:otherwise>
</c:choose>

 <form name="logoutForm" id="logoutForm" method="post" target="logoutFrm" action="disSession.asp">
 </form>
 
<form name="rdForm" method="post" action="./tax.do" target="loginFrm">
	<input type="hidden" name="fld1" id="fld1" value="">
	<input type="hidden" name="fld2" id="fld2" value="">
	<input type="hidden" name="fld3" id="fld3" value="">
	<input type="hidden" name="submitYear" id="submitYear" value="">
</form>
<center>
</body>
</html>