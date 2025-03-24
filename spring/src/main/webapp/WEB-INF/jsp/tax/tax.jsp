<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 전자세금계산서 조회
-- 작성자 : 박예진
-- 최초 작성일 : 2020-09-03 18:20:36
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
<!-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script> -->
<%-- <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/> --%>
	<script type="text/javascript">
	
// 		$(document).ready(function() {
// 			fnCheck();
// 		});
		
		function fnCheck() {
			var checkYn = ${checkYn};
			if(checkYn == "N") {
				alert("조회된 자료가 없습니다.");
				window.close();
			}
		}
		
		function onLoad() {
			fnCheck();
			window.resizeTo(983,677);
			var totalAmt = "";
			var taxbillAmt = "";
			var vatAmt = "";
// 			var taxbillTypeCd = $("#taxbill_type_cd").val();
			var taxbillTypeCd = document.getElementById("taxbill_type_cd").value;
	
			if(taxbillTypeCd == "1"){
// 				$("#receipt").text("영수");
				document.getElementById("receipt").innerHTML = "영수"
			} else if(taxbillTypeCd == "2"){
// 				$("#receipt").text("청구");
				document.getElementById("receipt").innerHTML = "청구"
			} else if(taxbillTypeCd == "3"){
// 				$("#receipt").text("카드발행");
				document.getElementById("receipt").innerHTML = "영수(카드)"
			} else if(taxbillTypeCd == "4"){
// 				$("#receipt").text("영수 청구");
				document.getElementById("receipt").innerHTML = "영수 청구"
			}
			
			totalAmt = totalAmt + (parseInt(document.getElementById("taxbillAmt").value) + parseInt(document.getElementById("vatAmt").value));
			taxbillAmt = chkComma(document.getElementById("taxbillAmt").value);
			vatAmt = chkComma(document.getElementById("vatAmt").value);
	
			totalAmt = chkComma(totalAmt);
	
			
			fillAmt();
// 			$("#total_amt").val(totalAmt);
// 			$("#taxbill_amt").text(taxbillAmt);
// 			$("#vat_amt").text(vatAmt);
			document.getElementById("total_amt").value = totalAmt;
			document.getElementById("taxbill_amt").innerHTML = ""+taxbillAmt+"";
			document.getElementById("vat_amt").innerHTML = ""+vatAmt+"";
		}
		
// 		function onLoad() {
// 			window.resizeTo(983,677);
// 			var totalAmt = "";
// 			var taxbillAmt = "";
// 			var vatAmt = "";
// 			var taxbillTypeCd = $M.getValue("taxbill_type_cd");
	
// 			if(taxbillTypeCd == "1"){
// 				$("#receipt").text("영수");
// 			} else if(taxbillTypeCd == "2"){
// 				$("#receipt").text("청구");
// 			} else if(taxbillTypeCd == "3"){
// 				$("#receipt").text("카드발행");
// 			} else if(taxbillTypeCd == "4"){
// 				$("#receipt").text("영수 청구");
// 			}
			
// 			totalAmt = totalAmt + ($M.toNum($("#taxbill_amt").text()) + $M.toNum($("#vat_amt").text()));
// 			taxbillAmt = $M.setComma($M.toNum($("#taxbill_amt").text()));
// 			vatAmt = $M.setComma($M.toNum($("#vat_amt").text()));
	
// 			totalAmt = $M.setComma(totalAmt);
	
			
// 			fillAmt();
// 			$("#total_amt").val(totalAmt);
// 			$("#taxbill_amt").text(taxbillAmt);
// 			$("#vat_amt").text(vatAmt);
// // 			document.getElementById("total_amt").value = totalAmt;
// // 			document.getElementById("taxbill_amt").innerHTML = ""+taxbillAmt+"";
// // 			document.getElementById("vat_amt").innerHTML = ""+vatAmt+"";
// 		}
	
		function chkComma(str){

		    var str2 = "";
			var chkVal = 0;

			for(var i = 0; i < str.length; i++){
				chkVal++;
				str2 = str2 + str.substring(str.length-1-i,str.length-i);   

				if(chkVal == 3 && i < str.length-1){
					str2 = str2 + ",";
					chkVal = 0;
				}
			}


			var str3 = "";
			for(var j = 0; j < str2.length; j++){
				str3 = str3 + str2.substring(str2.length-1-j, str2.length-j);
			}

			return str3;
		}
	
		function fillAmt(){
	
			var str = document.getElementById("taxbillAmt").value;

			var blankCnt = sum_price.length-str.length;
	
			for(var i = 0; i < str.length; i++){		
				if(i < sum_price.length){
					sum_price[(sum_price.length-1)-i].value = str.substring(str.length-1-i, str.length-i);
				}
			}
	
			
			str = document.getElementById("vatAmt").value;
	
			for(var i = 0; i < str.length; i++){		
				if(i < sum_tax.length){
					sum_tax[(sum_tax.length-1)-i].value = str.substring(str.length-1-i, str.length-i);
				}
			}
			document.getElementById("blank_cnt").value = blankCnt;
	
		}
		
		function printArea() {
			document.getElementById('prtArea').style.display = 'none';
			window.print();
		}
	
	</script>
</head>
 <style>
 	@page a4sheet{ size: 21.0cm 29.7cm }
	.a4{ page: a4sheet; page-break-after: always}
	a { font-family: ""; text-decoration: none; color=#000000} 
	a img{ border:none;}
	input{ width:20px; }
	td.bk_style1{ text-align:center;background-color:white;border-style:solid;border-color:#0000FF;border-bottom-color:#ffffff;border-right-color:#ffffff;border-width:1px; margin:1px;padding:2 0 0 0; border-collapse:1px; font-size:80% }
	td.bk_style2{ background-color:white;border-style:solid;border-color:#0000FF;border-bottom-color:#ffffff;border-width:1px; margin:1px;padding:2 0 0 0; font-size:80%}
	td.bk_style3{ background-color:white;border-style:solid;border-color:#0000FF;border-bottom-color:#ffffff;border-right-color:#ffffff;border-width:1px; margin:1px;padding:2 0 0 0; font-size:80%}    
	input.bk_input_style{ background-color:white; border-style:none; width:100%}  
	td.bk_style4{ background-color:white;border-style:solid;border-color:#0000FF;border-bottom-color:#0000ff;border-right-color:#ffffff;border-width:1px; margin:1px;padding:2 0 0 0; font-size:80%}    
	input.bk_input_style{ background-color:white; border-style:none; width:100%}    
	input:not([type="image" i]) { box-sizing: border-box; }
}
</style>
<body width="783" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="javascript:onLoad();">
<div id="box">
<input type="hidden" id="taxbill_type_cd" name="taxbill_type_cd" value="${taxInfo.taxbill_type_cd}">
<input type="hidden" id="taxbill_control_no" name="taxbill_control_no" value="${taxInfo.taxbill_control_no}">
<input type="hidden" id="slipno" name="slipno" value="${taxInfo.slipno}">
<input type="hidden" id="taxbillAmt" name="taxbillAmt" value="${taxInfo.taxbill_amt}">
<input type="hidden" id="vatAmt" name="vatAmt" value="${taxInfo.vat_amt}">
<input type="hidden" name="blank_cnt" id = "blank_cnt" class="bk_input_style" readonly style="text-align:center">
<table width="763" border="0" cellspacing="0" cellpadding="0">
  <tr> 
	<td> 
	  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr> 
		  <td height="55" align="right" background="img/01.gif" style="padding:2 10 0 0"><a href="logout.asp"></a><a href="edit.asp"></a></td>
		</tr>
		<tr> 
		  <td> 
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
			  <tr> 
				<td width="720" valign="top" style="padding:2 0 0 6"> 

<table width="733" border="0" cellpadding="5" cellspacing="1" bgcolor="B2B1A9">		
	<tr>
	  <td bgcolor="ECE9D8"><table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
		  <td><!-- 책번호 s -->
				<table width="100%" cellpadding="0" cellspacing="0">
				  <tr>
					<td rowspan="2" align="center" class="bk_style1"><b><font size="4">전자세금계산서(공급받는자 보관용)</b></td>
					<td width="81" align="center" class="bk_style1">책번호</td>
					<td colspan="2" class="bk_style3"><input name="kwon" type="text" class="bk_input_style" id="kwon" _tabindex="1" maxlength="4" _required hname="권" option="number"></td>
					<td align="right" class="bk_style3" align="center">권</td>
					<td colspan="3" class="bk_style3"><input name="ho" type="text" class="bk_input_style" id="ho" _tabindex="2" maxlength="4"  _required hname="호" option="number"></td>
					<td align="right" class="bk_style2" align="center">호</td>
				  </tr>
				  <tr>
					<td align="center" class="bk_style1">일련번호</td>
					<td width="20" class="bk_style3"><input name="num" _tabindex="3" align="center" type="text" class="bk_input_style" maxlength="1"  _required hname="일련번호" option="number" readonly></td>
					<td width="20" class="bk_style3"><input name="num" _tabindex="4" align="center" type="text" class="bk_input_style" maxlength="1"  _required hname="일련번호" option="number" readonly></td>
					<td width="20" class="bk_style1" align="center"> - </td>
					<td width="20" class="bk_style3"><input name="num" _tabindex="5" align="center" type="text" class="bk_input_style" maxlength="1"  _required hname="일련번호" option="number" readonly></td>
					<td width="20" class="bk_style3"><input name="num" _tabindex="6" align="center" type="text" class="bk_input_style" maxlength="1"  _required hname="일련번호" option="number" readonly></td>
					<td width="20" class="bk_style3"><input name="num" _tabindex="7" align="center" type="text" class="bk_input_style" maxlength="1"  _required hname="일련번호" option="number" readonly></td>
					<td width="20" class="bk_style2"><input name="num" _tabindex="8" align="center" type="text" class="bk_input_style" maxlength="1"  _required hname="일련번호" option="number" readonly></td>
				  </tr>
				</table>
			<!-- 책번호 e -->
		  </td>
		</tr>
		<tr>
		  <td><!-- 공급자 s -->
				<table width="100%" cellpadding="0" cellspacing="0">
				  <tr>
					<td width="2%" class="bk_style1" align="center">공<br>
						<br>
					  급<br>
					  <br>
					  자 </td>
					<td width="45%"><table width="100%" cellpadding="0" cellspacing="0">
					  <tr>
						<td width="10%" class="bk_style1">등록번호</td>
						<td colspan="3" class="bk_style3" align="center">${ykInfo.breg_no}</td>
					  </tr>
					  <tr>
						<td class="bk_style1">상 호<br>
						  (법인명)</td>
						<td width="14%" class="bk_style3">${ykInfo.breg_name}</td>
						<td width="9%" class="bk_style1">성 명<br>
						  (대표자) </td>
						<td width="14%" class="bk_style3" style="background:white url(http://admin.sunnyyk.co.kr/img/yk_dj.jpg) no-repeat 40% bottom ">${ykInfo.breg_rep_name}</td>
					  </tr>
					  <tr>
						<td class="bk_style1">사업장<br>
						  주 소</td>
						<td colspan="3" class="bk_style3">${ykInfo.biz_addr1}</td>
					  </tr>
					  <tr>
						<td class="bk_style1">업 태</td>
						<td class="bk_style3">${ykInfo.breg_cor_type}</td>
						<td class="bk_style1" style="height:34px">종 목</td>
						<td class="bk_style3">${ykInfo.breg_cor_part}</td>
					  </tr>
					</table></td>
					<td width="2%" class="bk_style1" align="center">공<br>
					  급<br>
					  받<br>
					  는<br>
					  자</td>
					<td width="45%"><table width="100%" cellpadding="0" cellspacing="0">
					  <tr>
						<td width="10%" class="bk_style1">등록번호</td>
						<td colspan="3" class="bk_style2" align="center">${taxInfo.breg_no}</td>
					  </tr>
					  <tr>
						<td class="bk_style1">상 호<br>
						  (법인명) </td>
						<td width="14%" class="bk_style3">${taxInfo.breg_name}</td>
						<td width="9%" class="bk_style1">성 명<br>
						  (대표자) </td>
						<td width="14%" class="bk_style2">${taxInfo.breg_rep_name}</td>
					  </tr>
					  <tr>
						<td class="bk_style1">사업장<br>
						  주 소</td>
						<td colspan="3" class="bk_style2">${taxInfo.biz_addr}</td>
					  </tr>
					  <tr>
						<td class="bk_style1">업 태</td>
						<td class="bk_style3">${taxInfo.breg_cor_type}</td>
						<td class="bk_style1" style="height:34px">종 목</td>
						<td class="bk_style2">${taxInfo.breg_cor_part}</td>
					  </tr>
					</table></td>
				  </tr>
				</table>
			<!-- 공급자 e -->
		  </td>
		</tr>
		<tr>
		  <td><!-- 세액계산 s -->
				<table width="100%" cellpadding="0" cellspacing="0">
				  <tr>
					<td colspan="3" class="bk_style1">작 성</td>
					<td colspan="11" class="bk_style1">공 급 가 액</td>
					<td colspan="10" class="bk_style1">세 액</td>
					<td colspan="2" align="center" class="bk_style2">수 정 사 유</td>
				  </tr>
				  <tr>
					<td width="20" class="bk_style1" align="center">년</td>
					<td width="20" class="bk_style1" align="center">월</td>
					<td width="20" class="bk_style1" align="center">일</td>
					<td width="20" class="bk_style1" align="center">백</td>
					<td width="20" class="bk_style1" align="center">십</td>
					<td width="20" class="bk_style1" align="center">억</td>
					<td width="20" class="bk_style1" align="center">천</td>
					<td width="20" class="bk_style1" align="center">백</td>
					<td width="20" class="bk_style1" align="center">십</td>
					<td width="20" class="bk_style1" align="center">만 </td>
					<td width="20" class="bk_style1" align="center">천</td>
					<td width="20" class="bk_style1" align="center">백</td>
					<td width="20" class="bk_style1" align="center">십</td>
					<td width="20" class="bk_style1" align="center">일</td>
					<td width="20" class="bk_style1" align="center">십</td>
					<td width="20" class="bk_style1" align="center">억</td>
					<td width="20" class="bk_style1" align="center">천</td>
					<td width="20" class="bk_style1" align="center">백</td>
					<td width="20" class="bk_style1" align="center">십</td>
					<td width="20" class="bk_style1" align="center">만</td>
					<td width="20" class="bk_style1" align="center">천</td>
					<td width="20" class="bk_style1" align="center">백</td>
					<td width="20" class="bk_style1" align="center">십</td>
					<td width="20" class="bk_style1" align="center">일</td>
					<td width="140" rowspan="2" class="bk_style2" align='center'>${taxInfo.mody_name}</td>
				  </tr>
				  <tr>
					<td class="bk_style3" align='center'>${taxInfo.year}</td>
					<td class="bk_style3" align='center'>${taxInfo.month}</td>
					<td class="bk_style3" align='center'>${taxInfo.day}</td>
					<td class="bk_style1"><b><input type="text" name="sum_price" id="sum_price" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_price" id="sum_price" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_price" id="sum_price" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_price" id="sum_price" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_price" id="sum_price" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_price" id="sum_price" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_price" id="sum_price" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_price" id="sum_price" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_price" id="sum_price" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_price" id="sum_price" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_price" id="sum_price" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_tax" id="sum_tax" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_tax" id="sum_tax" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_tax" id="sum_tax" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_tax" id="sum_tax" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_tax" id="sum_tax" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_tax" id="sum_tax" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_tax" id="sum_tax" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_tax" id="sum_tax" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_tax" id="sum_tax" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
					<td class="bk_style1"><b><input type="text" name="sum_tax" id="sum_tax" class="bk_input_style" readonly style="text-align:center;font-weight:bold" maxlength="1"></b></td>
				  </tr>
				  <tr rowspan="2" style="height:40px">
				  	<td colspan="3" class="bk_style1">비 고</td>
				  	<td class="bk_style2" colspan="22" style="padding : 5px 5px;">${taxInfo.note1}</td>
				  </tr>
				</table>
			<!-- 세액계산 e -->
		  </td>
		</tr>
		<tr>
		  <td><!-- 품목입력 s -->
				<table width="100%" cellpadding="0" cellspacing="0">
				  <tr>
					<td width="20" class="bk_style1">월 </td>
					<td width="20" class="bk_style1">일 </td>
					<td class="bk_style1">품 목</td>
					<td width="60" class="bk_style1">규 격</td>
					<td width="50" class="bk_style1">수 량</td>
					<td width="80" class="bk_style1">단 가</td>
					<td width="100" class="bk_style1">공급가액 </td>
					<td width="80" class="bk_style2" align="center">세 액</td>                    
				  </tr>
				  
				  <tr>
					<td class="bk_style3" align='center'>${taxInfo.month}</td>
					<td class="bk_style3" align='center'>${taxInfo.day}</td>
					<td class="bk_style3">${taxInfo.desc_text}</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3" align="right" id="taxbill_amt">${taxInfo.taxbill_amt}</td>
					<td class="bk_style2" align="right" id="vat_amt">${taxInfo.vat_amt}</td>
					
				  </tr>
				  
				 <tr>
					<td class="bk_style3" align='center'>&nbsp;</td>
					<td class="bk_style3" align='center'>&nbsp;</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3" align="right" id="taxbill_amt">&nbsp;</td>
					<td class="bk_style2" align="right" id="vat_amt">&nbsp;</td>
					
				  </tr>
				  
				 <tr>
					<td class="bk_style3" align='center'>&nbsp;</td>
					<td class="bk_style3" align='center'>&nbsp;</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3" align="right" id="taxbill_amt">&nbsp;</td>
					<td class="bk_style2" align="right" id="vat_amt">&nbsp;</td>
					
				  </tr>
				  
				 <tr>
					<td class="bk_style3" align='center'>&nbsp;</td>
					<td class="bk_style3" align='center'>&nbsp;</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3">&nbsp;</td>
					<td class="bk_style3" align="right" id="taxbill_amt">&nbsp;</td>
					<td class="bk_style2" align="right" id="vat_amt">&nbsp;</td>
					
				  </tr>
				  
				</table>
			<!-- 품목입력 e -->
		  </td>
		</tr>
		<tr>
		  <td><!-- 합계 s -->
				<table width="100%" cellpadding="0" cellspacing="0">
				  <tr>
					<td width="15%" class="bk_style1">합 계 금 액</td>
					<td width="15%" class="bk_style1">현 금</td>
					<td width="15%" class="bk_style1">수 표</td>
					<td width="15%" class="bk_style1">어 음</td>
					<td width="15%" class="bk_style1">외상미수금</td>
					<td width="25%" rowspan="2" class="bk_style2"><table width="100%" border="0" cellspacing="0" cellpadding="0">
						<tr>
						  <td height="44px" rowspan="2" align="center" style="background-color:white;border-style:solid;border-color:#ffffff;border-bottom-color:#0000ff;border-width:1px; margin:1px;padding:2 0 0 0; font-size:80%">이 금액을 <span id='receipt'></span> 함.</td>                          
						</tr>                        
					</table></td>
				  </tr>
				  <tr>
					<td class="bk_style4"><input type="text" style="text-align:right" id="total_amt" name="total_amt" value="" class="bk_input_style" readonly></td>
					<td class="bk_style4"><input onKeyUp="checkValid(this);this.value=inputcomma(this.value);applySum();" type="text" style="text-align:right" name="tot_cash" value="" class="bk_input_style"></td>
					<td class="bk_style4"><input onKeyUp="checkValid(this);this.value=inputcomma(this.value);applySum();" type="text" style="text-align:right" name="tot_check" value="" class="bk_input_style"></td>
					<td class="bk_style4"><input onKeyUp="checkValid(this);this.value=inputcomma(this.value);applySum();" type="text" style="text-align:right" name="tot_paper" value="" class="bk_input_style"></td>
					<td class="bk_style4"><input onKeyUp="this.value=inputcomma(this.value);checkValid(this)" type="text" style="text-align:right" name="tot_notpay" value="" class="bk_input_style" readonly></td>
				  </tr>
				</table>
			<!-- 합계 e -->
		  </td>
		</tr>					
		<tr>
		  <td align="left" style="padding:20"></td>
		</tr>
	  </table></td>
	</tr>			 
</table>
<font size=1>${taxInfo.issu_id}</font>

				</td>               
			  </tr>
			</table>
		  </td>
		</tr>        
	  </table>
	</td>
  </tr>
  <tr> 
	<td> * 전자세금계산서발행으로 국세청신고 건</td>
  </tr>

  </div>			  
</table><br><br>
<div id='prtArea'>
  <table>
  <tr> 
	<td>&nbsp;&nbsp;&nbsp;&nbsp;<a href="#" onClick="javascript:printArea();"><img src="http://erp.sunnyyk.co.kr/img/btn_print.gif"></a>
	<!-- <a href="#" onClick="javascript:history.back();"><img src="http://erp.sunnyyk.co.kr/img/btn_back.gif"></a> --></td>
  </tr>
  <tr>
	<td style="font-size:80%"> 출력이 정상적으로 되지 않으실 경우 브라우저의 파일-페이지 설정에서 여백을 3mm 이하로 줄여 주시고<br> 브라우저의 도구-인터넷옵션-고급 에서 이미지 및 배경색 인쇄를 체크해 주세요.
	</td>
  </tr>
  </table>
  </div>
</body>
</html>