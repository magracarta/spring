<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 사업자관리/등록 > null > 사업자정보상세
-- 작성자 : 손광진
-- 최초 작성일 : 2020-01-29 15:34:25
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
</head>
	<script type="text/javascript">
		
		$(document).ready(function() {
			// 주민번호 체크 시 input 변경
			fnSetInput();
		});

		
		//팝업 끄기
		function fnClose() {
			window.close();
		}
		
		
		//등록고객 검색 팝업
		function goMemberPopup() {
			var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=900, left=0, top=0";
			$M.goNextPage('/comp/comp0301', "", {popupStatus : popupOption});
		}
		
		// 상세보기 화면 세팅
		function fnSetInput() {
			if($M.getValue("breg_type_cd") == "PER") {
				$("#breg_name").attr("disabled", true);
				$("#breg_name").addClass("cust-edit-disabled");
			}
			$("#cust_name_btn").attr("disabled", true);
			$("#cust_name_btn").addClass("cust-edit-disabled");
		}
		
		// 수정
		function goModify() {
			
			// 등록고객 변경 불가
			
		  	// validation check
	     	if($M.validation(document.main_form) === false) {
	     		return;
	     	};
	     	
			var frm = document.main_form;
			var bregSeq = $M.getValue("breg_seq");	// 사업자 일련번호
			
			$M.goNextPageAjaxModify(this_page + "/" + bregSeq + "/modify", $M.toValueForm(frm), { method : "POST"},
				function(result) {
					if(result.success) {
                        location.reload();
					};
				}
			);
		}
		
		// 삭제 사용여부 = N 으로 변경
		function goRemove() {
			var bregSeq = $M.getValue("breg_seq");	// 사업자 일련번호
			var custNo = $M.getValue("cust_no");	// 고객번호
			
			var param = {
					breg_seq : $M.getValue("breg_seq"),
					cust_no : $M.getValue("cust_no")
			}
			
			
			$M.goNextPageAjaxRemove(this_page + "/" + bregSeq + "/remove", $M.toGetParam(param), { method : "POST"},
				function(result) {
					if(result.success) {
						location.reload();
					};
				}
			);
		}
		// 사업장 주소
		function setAddrArea(data) {
			$M.setValue("biz_post_no", data.zipNo);
			$M.setValue("biz_addr1", data.roadAddrPart1);
			$M.setValue("biz_addr2", data.addrDetail);
		}

		// 사업자 주소
		function setAddrPerson(data) {
			$M.setValue("rep_post_no", data.zipNo);
			$M.setValue("rep_addr1", data.roadAddrPart1);
			$M.setValue("rep_addr2", data.addrDetail);
		}
		
		function fnSendMail() {
			var param = {
	    			 'to' : $M.getValue('taxbill_email')
	    	  };
	        openSendEmailPanel($M.toGetParam(param));
		}

		// [18100] 상세주소반영 - 김경빈
		function fnSetCustomAddr() {
			// 우편번호 00000으로 세팅
			$M.setValue("biz_post_no", "00000");
			// 상세주소의 내용을 메인주소로 변경
			$M.setValue("biz_addr1", $M.getValue("biz_addr2"));
			// 상세주소 내용 삭제
			$M.setValue("biz_addr2", "");
		}

	</script>
	<style>
	 /* 비활성화 처리 */
	.cust-edit-disabled {
		cursor: not-allowed;
		border: 1px solid #ddd;
		color:#ccc;
	}
	</style>
<body class="bg-white">
	<form id="main_form" name="main_form">
		<input type="hidden" name="cust_no" value="${result.cust_no}">
		<input type="hidden" name="cust_name" value="${result.cust_name}">
		<input type="hidden" name="breg_seq" value="${result.breg_seq}">
		<input type="hidden" name="breg_type_cd" value="${result.breg_type_cd}">
		<!-- 팝업 -->
	    <div class="popup-wrap width-100per">
	    
			<!-- 타이틀영역 -->
	        <div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /타이틀영역 -->
	        <div class="content-wrap">
			<!-- 폼테이블 -->				
				<div>
					<div class="title-wrap">
						<h4>사업자정보상세</h4>
					</div>	
					<table class="table-border mt5">
						<colgroup>
							<col width="140px">
							<col width="">
							<col width="140px">
							<col width="">
							<col width="140px">
							<col width="">
							<col width="140px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right essential-item">사업자등록구분</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
								<td>
									<c:forEach var="breg" items="${codeMap['BREG_TYPE']}">
	 								<div class="form-check form-check-inline">
										<input type="radio" name="breg_type_cd" disabled="disabled" class="cust-edit-disabled" alt="사업자등록구분" onchange="fnSetBregType(this.value);" value="${breg.code_value}" ${breg.code_value == "" ? "checked='checked'" : "" } ${result.breg_type_cd eq breg.code_value ? "checked='checked'" : "" } >
										<label class="form-check-label">${breg.code_name}</label>
									</div>
									</c:forEach>
								</td>	
								<th class="text-right">사업자번호</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
								<td>
									<input type="text" id="" name="" disabled="disabled" class="form-control cust-edit-disabled width120px" value="${result.breg_no}" minlength="10" maxlength="13" placeholder="-없이 숫자만 입력" alt="사업자번호" >
								</td>
								<th class="text-right essential-item">업체명</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
								<td>
									<input type="text" id="breg_name" name="breg_name" class="form-control essential-bg width120px" alt="업체명" required="required" value="${result.breg_name}">
								</td>	
								<th class="text-right essential-item">사용여부</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="use_yn" value="Y" ${result.use_yn eq "Y" ? "checked" : ""}>
										<label class="form-check-label">사용</label>
									</div>
									<div class="form-cheRck form-check-inline">
										<input class="form-check-input" type="radio" name="use_yn" value="N" ${result.use_yn eq "N" ? "checked" : ""}>
										<label class="form-check-label">사용안함</label>
									</div>
								</td>									
							</tr>
							<tr>
								<th class="text-right essential-item">대표자</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
								<td>
									<input type="text" id="breg_rep_name" name="breg_rep_name" class="form-control width120px essential-bg" alt="대표자" value="${result.breg_rep_name}" required="required">
								</td>	
								<th class="text-right">법인등록번호</th>
								<td>
									<input type="text" id="breg_cor_no" name="breg_cor_no" class="form-control" placeholder="-없이 숫자만 입력" value="${result.breg_cor_no}">
								</td>	
								<th class="text-right">업태</th>
								<td>
									<input type="text" id="breg_cor_type" name="breg_cor_type" class="form-control width120px" value="${result.breg_cor_type}" alt="업태">
								</td>
								<th class="text-right">업종</th>
								<td>
									<input type="text" id="breg_cor_part" name="breg_cor_part" class="form-control width120px" value="${result.breg_cor_part}" alt="업종">
								</td>											
							</tr>
							<tr>
								<th class="text-right">설립일</th>
								<td>
									<div class="input-group">
										<input type="text" id="breg_open_dt" name="breg_open_dt" class="form-control border-right-0 calDate"  dateFormat="yyyy-MM-dd" alt="설립일" value="${result.breg_open_dt}"> 
									</div>
								</td>		
								<th class="text-right">폐업일</th>
								<td>
									<div class="input-group">
										<input type="text" id="breg_close_dt" name="breg_close_dt" class="form-control border-right-0 calDate" dateFormat="yyyy-MM-dd" alt="폐업일" value="${result.breg_close_dt}"> 
									</div>
								</td>
								<!-- ##개발 예정 -->
								<th class="text-right">계산서발행이메일</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-8">
											<input type="text" class="form-control" id="taxbill_email" name="taxbill_email" value="${result.taxbill_email}" maxlength="100">
										</div>	
										<div class="col-2">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendMail();"><i class="material-iconsmail"></i></button>	
										</div>									
									</div>
								</td>	
								<th class="text-right">등록고객</th>
								<td>
									<div class="input-group">
										<input type="text" id="cust_name" name="cust_name" class="form-control border-right-0 cust-edit-disabled width120px" disabled="disabled" value="${result.cust_name}">
										<button type="button" id="cust_name_btn" class="btn btn-icon btn-primary-gra" disabled="disabled"><i class="material-iconssearch"></i></button>
									</div>
								</td>								
							</tr>
							<tr>
								<th class="text-right essential-item">사업장주소</th>
								<td colspan="3">
									<div class="form-row inline-pd mb7">
										<div class="col-4">
											<input type="text" id="biz_post_no" name="biz_post_no" class="form-control" value="${result.biz_post_no}" alt="우편번호" required="required" readonly="readonly">
										</div>
										<div class="col-4">
											<button type="button" onclick="openSearchAddrPanel('setAddrArea')" class="btn btn-primary-gra">주소찾기</button>
										</div>
										<!-- [18100] 상세주소반영 버튼 추가 - 김경빈 -->
										<div class="col-4" style="text-align: right;">
											<button type="button" class="btn btn-primary-gra" onclick="fnSetCustomAddr()">상세주소반영</button>
										</div>
									</div>
									<div class="form-row inline-pd mb7">
										<div class="col-12">
											<input type="text" id="biz_addr1" name="biz_addr1" class="form-control" value="${result.biz_addr1}" alt="주소" required="required" readonly="readonly">
										</div>
									</div>
									<div class="form-row inline-pd">
										<div class="col-12">
											<input type="text" id="biz_addr2" name="biz_addr2" class="form-control" value="${result.biz_addr2}">
										</div>
									</div>
								</td>
								<th class="text-right">사업자주소</th>
								<td colspan="3">
									<div class="form-row inline-pd mb7">
										<div class="col-4">
											<input type="text" id="rep_post_no" name="rep_post_no" class="form-control" value="${result.rep_post_no}">
										</div>
										<div class="col-8">
											<button type="button" onclick="javascript:openSearchAddrPanel('setAddrPerson');" class="btn btn-primary-gra">주소찾기</button>
										</div>								
									</div>
									<div class="form-row inline-pd mb7">
										<div class="col-12">
											<input type="text" id="rep_addr1" name="rep_addr1" class="form-control" value="${result.rep_addr1}">
										</div>
									</div>
									<div class="form-row inline-pd">
										<div class="col-12">
											<input type="text" id="rep_addr2" name="rep_addr2" class="form-control" value="${result.rep_addr2}">
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">세금계산서안내휴대전화</th>
								<td>
									<input type="text" id="tax_notice_phone_no" name="tax_notice_phone_no" class="form-control width120px" format="phone" datatype="int" minlength=9 maxlength=11 value="${result.tax_notice_phone_no}">
								</td>
								<th class="text-right">사업장기타사항</th>
								<td>
									<input type="text" id="breg_rep_bigo" name="breg_rep_bigo" class="form-control"  maxlength="100" value="${result.breg_rep_bigo}">
								</td>
								<th class="text-right">비고</th>
								<td colspan="3">
									<input type="text" id="bigo" name="bigo" class="form-control" value="${result.bigo}">
								</td>
							</tr>											
						</tbody>
					</table>
				</div>		
				<!-- /폼테이블 -->	
				<div class="btn-group mt10">
					<div class="left text-warning ml5" style="width:70%;">
					※ 주민번호로 등록 시 인감주소를 사업장주소에 입력 바랍니다.  
					</div>
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