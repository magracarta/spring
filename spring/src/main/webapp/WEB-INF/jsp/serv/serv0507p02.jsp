<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > SA-R신청관리 > null > SA-R추가등록
-- 작성자 : 이강원
-- 최초 작성일 : 2022-09-20 15:39:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	$(document).ready(function() {
		fnInitPage();
	});
	
	function fnInitPage() {
		var sarStatusCd = $M.getValue("machine_sar_status_cd");
		$M.setValue("__s_cust_no", "${map.cust_no}");
		if(sarStatusCd == "R") {
			$(".statusC").addClass("essential-item");
			$(".statusC-input").addClass("sale-rb");
		}
	}
		
	function fnClose() {
		window.close();
	}
	
	
// 	// 검색 엔터키 이벤트
// 	function enter(fieldObj) {
// 		var field = ["cust_deal_no"];
// 		$.each(field, function() {
// 			if(fieldObj.name == this) {
// 				goSearchDealCustNo();
// 			};
// 		});
// 	}
	
// 	function goCustInfoClick() {
// 		var param = {
// 				s_cust_no : $M.getValue("cust_deal_no")
// 		};
// 		openSearchCustPanel('fnSetDealCustNo', $M.toGetParam(param));
// 	}
	
// 	function fnSetDealCustNo(data){
// 		$M.setValue("cust_deal_no",data.cust_no)
// 	}
	
// 	function goSearchDealCustNo(){
// 		if($M.validation(null, {field:['cust_deal_no']}) == false) { 
// 			return;
// 		}
// 		var param = {
// 				s_cust_no : $M.getValue("cust_deal_no")
// 		};
// 		var url = "/comp/comp0301";
// 		$M.goNextPageAjax(url + "/search", $M.toGetParam(param), {method : 'get'},
// 			function(result) {
// 				if(result.success) {
// 					var list = result.list;
// 					switch(list.length) {
// 						case 0 :
// 							$M.clearValue({field:["cust_deal_no"]});
// 							break;
// 						case 1 : 
// 							var row = list[0];
// 							fnSetDealCustNo(row);
// 							break;
// 						default :
// 							openSearchCustPanel('fnSetDealCustNo', $M.toGetParam(param));
// 						break;
// 					}
// 				}
// 			}
// 		);
// 	}
	
	
	
	function goUpdateSAR(type) {
		var msg = "";
		var param = {
			machine_seq : $M.getValue("machine_seq"),
			cust_no : $M.getValue("cust_no"),
			cust_name : $M.getValue("cust_name"),
			machine_doc_no : $M.getValue("machine_doc_no"),
			cust_eng_name : $M.getValue("cust_eng_name"),
			cust_hp_no : $M.getValue("cust_hp_no"),
			cust_email : $M.getValue("cust_email"),
			remark : $M.getValue("remark"),
			file_seq : $M.getValue("sar_file_seq"),
			reg_date : $M.getValue("reg_date"),
			new_yn : "N",
			show_yn : "Y",
			machine_sar_status_cd : type
		};
		
		if($M.validation(document.main_form) == false) {
			return;
		}
		
		if(type == "S") { //작성, 계약 상태 두가지의 경우가 있음(상태유지)
			param.machine_sar_status_cd = "WS";
			if($M.getValue("machine_sar_status_cd") != 'W'){
				param.cust_deal_no = $M.getValue("cust_deal_no");
				param.contract_no = $M.getValue("contract_no");
				param.contract_st_dt = $M.getValue("s_start_dt");
				param.contract_ed_dt = $M.getValue("s_end_dt");
				param.machine_sar_status_cd = "RS";
				if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
					return;
				}
			}
			msg = "저장하시겠습니까?";
		}else if(type == "C") {
			if($M.validation(document.main_form, {field:["contract_no", "cust_deal_no", "s_start_dt", "s_end_dt"]}) == false) {
				return false;
			};
			param.cust_deal_no = $M.getValue("cust_deal_no");
			param.contract_no = $M.getValue("contract_no");
			param.contract_st_dt = $M.getValue("s_start_dt");
			param.contract_ed_dt = $M.getValue("s_end_dt");
			msg = "계약처리 하시겠습니까?";
			
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
				return;
			}
			
		}else if(type == "R") {
			msg = "신청처리 하시겠습니까?";
		}else if(type == "D") {
			msg = "미신청처리 하시겠습니까?";
		}else if(type == "W") {
			param.contract_st_dt = "";
			param.contract_ed_dt = "";
			param.req_date = "";
			param.contract_no = "";
			param.contract_date = "";
			msg = "반려처리 하시겠습니까?";
		}else {
			msg = "만료처리 하시겠습니까?";
		}
		
		$M.goNextPageAjaxMsg(msg,this_page+"/save", $M.toGetParam(param), {method : "POST"},
			function(result) {
				if(result.success) {
					alert("처리가 완료되었습니다.");
					fnClose();
					if (opener != null && opener.goSearch) {
						opener.goSearch();
					}
			}
		}); 
		
	}
	function goComplete() { //신청처리
		goUpdateSAR("R");
	}
	
	function goConfirm() { //미신청처리
		goUpdateSAR("D");
	}
	
	function goCompanion() { //반려
		goUpdateSAR("W"); //작성상태로 변경
	}
	
	function goApplyCompanion() { //반려
		goUpdateSAR("W"); //작성상태로 변경
	}
	
	function goExpiration() { //만료
		goUpdateSAR("E");
	}
	
	function goSave() { //저장
		goUpdateSAR("S"); 
	}
	
	function goContractProcess() { //계약처리
		goUpdateSAR("C");
	}
	
	// 업무DB 연결 함수 21-08-06이강원
 	function openWorkDB(){
 		openWorkDBPanel($M.getValue("machine_seq"));
 	}

	// 파일첨부팝업
	function goFileUploadPopup() {
		var param = {
			upload_type : 'SALE',
			file_type : 'both',
			file_ext_type : 'pdf#img',
			max_size : 5000
		}
		openFileUploadPanel('fnSetFile', $M.toGetParam(param));
	}

	function fnSetFile(file) {
		fnPrintFile(file.file_seq, file.file_name);
	}

	// 파일세팅
	function fnPrintFile(fileSeq, fileName) {
		var str = '';
		str += '<div class="table-attfile-item submit">';
		str += '<a href="javascript:fileDownload(' + fileSeq + ');">' + fileName + '</a>&nbsp;';
		str += '<input type="hidden" name="sar_file_seq" value="' + fileSeq + '"/>';
		str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile()"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '</div>';
		$('.submit_div').append(str);
		$("#btn_submit").remove();
	}

	// 첨부파일 삭제
	function fnRemoveFile() {
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".submit").remove();
			var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit">파일찾기</button>'
			$('.submit_div').append(str);
		} else {
			return false;
		}
	}

	// 첨부파일 리셋
	function fnResetFile() {
		$(".submit").remove();
		$("#btn_submit").remove();
		var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit">파일찾기</button>'
		$('.submit_div').append(str);
	}

	// 장비대장
	function goMachineDetail() {
		var machineSeq = $M.getValue("machine_seq");

		// 보낼 데이터
		var params = {
			"s_machine_seq" : machineSeq
		};

		var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
		$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus : popupOption});
	}


	</script>
</head>
<body class="bg-white class">
	<form id="main_form" name="main_form">
		<input type="hidden" id="machine_seq" name="machine_seq" value="${map.machine_seq}">
		<input type="hidden" id="cust_no" name="cust_no" value="${map.cust_no}">
		<input type="hidden" id="machine_sar_status_cd" name="machine_sar_status_cd" value="${map.machine_sar_status_cd}">
		<input type="hidden" id="use_yn" name="use_yn" value="${map.use_yn}">
 		<!-- 팝업 -->
	    <div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	        <div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	        </div>
	<!-- /타이틀영역 -->
	        <div class="content-wrap">
				<div class="row">
					<div class="col-5">
	<!-- 신청정보 -->				
						<div>
							<div class="title-wrap">
								<h4>신청정보</h4>				
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right">관리번호</th>
										<td>
											<input type="text" id="machine_doc_no" name="machine_doc_no" value="${map.machine_doc_no}" class="form-control width160px" readonly>
										</td>
									</tr>
									<tr>
										<th class="text-right">고객명</th>
										<td>
											<div class="form-row inline-pd pr">
												<div class="col-auto">
													<input type="text" id="cust_name" name="cust_name" value="${map.cust_name}" class="form-control width160px" readonly>
												</div>
												<div class="col-auto">
													<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
						 	                     		<jsp:param name="li_type" value="__cust_dtl"/>
							                     	</jsp:include>
												</div>
					                     	</div>
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">영문명</th>
										<td>
											<input type="text" id="cust_eng_name" name="cust_eng_name" value="${map.cust_eng_name}" class="form-control width160px rb" style="text-transform:uppercase" required="required">
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">연락처</th>
										<td>
											<input type="text" id="cust_hp_no" name="cust_hp_no" format="phone" value="${map.cust_hp_no}" class="form-control width160px rb" required="required">
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">이메일</th>
										<td>
											<input type="text" id="cust_email" name="cust_email" value="${map.cust_email}" class="form-control width160px rb" required="required" maxlength="100">
										</td>
									</tr>
									<tr>
										<th class="text-right">모델명</th>
										<td>
											<div class="form-row inline-pd pr">
												<div class="col-auto">
													<input type="text" id="machine_name" name ="machine_name" value="${map.machine_name}" class="form-control width160px" readonly>
												</div>
												<div class="col-auto">
							                        <button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
									            </div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">차대번호</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-8">
													<input type="text" id="body_no" name="body_no" value="${map.body_no}" class="form-control width160px" readonly>
												</div>
												<div class="col-auto">
													<button type="button" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goMachineDetail()">장비대장</button>
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">출하일자</th>
										<td>
											<input type="text" id="out_dt" name="out_dt" value="${map.out_dt}" class="form-control width160px" readonly>
										</td>
									</tr>
									<tr>
										<th class="text-right">담당센터</th>
										<td>
											<input type="text" id="center_org_code" name="center_org_code" value="${map.center_org_name}" class="form-control width160px" readonly>
										</td>
									</tr>
									<tr>
										<th class="text-right">마케팅담당</th>
										<td>
											<input type="text" id="sale_mem_no" name="sale_mem_no" value="${map.sale_mem_name}" class="form-control width160px" readonly>
										</td>
									</tr>
									<tr>
										<th class="text-right">신청일시</th>
										<td>
											<fmt:formatDate value="${map.req_date}" pattern="yyyy-MM-dd HH:mm:ss" var="req_date"/>
											<input type="text" id="req_date" name="req_date" value="${req_date}" class="form-control width160px" readonly>
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">작성일자</th>
										<td>
											<div class="input-group width120px">
												<input type="text" class="form-control border-right-0 calDate statusC-input" id="reg_date" name="reg_date" dateFormat="yyyy-MM-dd" value="${map.reg_date}" alt="작성일자" required="required">
											</div>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
	<!-- /신청정보 -->								
					</div>
					<div class="col-7">
	<!-- 계약정보 -->				
						<div>
							<div class="title-wrap">
								<h4>계약정보</h4>				
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right">계약상태</th>
										<td>${map.machine_sar_status_name }</td>
									</tr>
									<tr>
										<th class="text-right statusC">계약번호</th>
										<td>
											<input type="text" id="contract_no" name="contract_no" value="${map.contract_no}" class="form-control width160px statusC-input" readonly>
										</td>
									</tr>
									<tr>
										<th class="text-right statusC">거래처코드</th>
										<td>
											<div class="form-row inline-pd pr">
												<div class="col-auto">
													<input type="text" id="cust_deal_no" name="cust_deal_no" value="${map.cust_deal_no}" class="form-control width160px statusC-input">
												</div>
												<div class="col-auto">
													<input type="text" id="ori_cust_name" name="ori_cust_name" value="${map.ori_cust_name}" class="form-control width100px" readonly>
												</div>
					                     	</div>										
								
										</td>
									</tr>
									<tr>
										<th class="text-right statusC">계약게시일</th>
										<td>
											<div class="input-group width120px">
												<input type="text" class="form-control border-right-0 calDate statusC-input" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" value="${map.contract_st_dt}" alt="계약게시일">
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right statusC">계약종료일</th>
										<td>
											<div class="input-group width120px">
												<input type="text" class="form-control border-right-0 calDate statusC-input" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd"  value="${map.contract_ed_dt}" alt="계약종료일">
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">비고</th>
										<td>
											<textarea id="remark" name="remark" class="form-control" style="height: 173px;" value="${map.remark}">${map.remark}</textarea>
										</td>
									</tr>
									<tr>
										<th class="text-right">계약처리일시</th>
										<td>
											<fmt:formatDate value="${map.contract_date}" pattern="yyyy-MM-dd HH:mm:ss" var="contract_date"/>
											<input type="text" id="contract_date" name="contract_date" value="${contract_date}" class="form-control width160px" readonly>
										</td>
									</tr>
									<tr>
										<th class="text-right">SA-R계약동의서</th>
										<td>
											<div class="table-attfile submit_div">
												<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit">파일찾기</button>
											</div>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
					<!-- /계약정보 -->							
					</div>
				</div>
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div> 
				</div>
	        </div>
	    </div>
	<!-- /팝업 -->
	</form>
</body>
</html>