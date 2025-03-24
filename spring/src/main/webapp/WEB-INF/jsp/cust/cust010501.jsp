<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 사업자관리/등록 > 사업자정보등록 > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-01-29 12:52:25
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			fnInitPage();
			$('#breg_no').on('keyup keypress',function(e) {
				var bregType = $M.getValue("breg_type_cd");	// 사업자등록구분 값
				var breg_no = $M.getValue("breg_no").toString();	// 주민번호 or 사업자번호 값
				if ( bregType == "PER" && breg_no.length == 13 ) {
					if ( !socialSecurityNumberCheck(breg_no) ){
						alert("유효한 주민등록번호가 아닙니다.\n확인 후 다시 입력하시기 바랍니다.");
					}
				}
			});
		})
		
		function fnInitPage() {
			var custNo = "${inputParam.cust_no}";
			if(custNo != "") {
				$M.setValue("cust_name", "${inputParam.cust_name}");
				$M.setValue("cust_no", custNo);
			}
			if($M.getValue("popup_yn") == "Y") {
				$("#_fnList").addClass("dpn");
			} else {
				$("#_fnClose").addClass("dpn");
			}
		}
		
		// 사업자등록구분 체크값에 따라 입력폼 변경
		function fnSetBregType(type) {
			// 주민번호 체크 시
			if(type == "PER") {
				$("#changeBregNo").text("주민번호");
				$("#breg_name").prop("readonly", true);
				$("#breg_name").removeClass("essential-bg");
				$M.setValue("breg_name", "");
			} else {
				$("#changeBregNo").text("사업자번호");
				$("#breg_name").prop("readonly", false);
				$("#breg_name").addClass("essential-bg");
			};
		}

		// 목록
		function fnList() {
			history.back();
			//$M.goNextPage('/cust/cust0105');
		}

		function socialSecurityNumberCheck(number){
			// if ( number.length != 13) return false;
			var keyArray = [2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5]; // 가중치 배열

			var totalchkSum = 0;
			for (var i = 0; i < keyArray.length; i++) // 앞 6자리
			{
				totalchkSum += number[i] * keyArray[i];
			}

			// (Q&A 17650) 외국인 주민번호 검증 추가. 2023-01-26 김상덕 (https://han288.tistory.com/139)
			// 한국
			var isKorPass = number[12] == (11 - totalchkSum % 11) % 10;
			// 외국
			var isForeignPass = number[12] == (13 - totalchkSum % 11) % 10;

			return isKorPass || isForeignPass;
		}
		
		// 저장
		function goSave() {
			
			var frm = document.main_form;
			var bregType = $M.getValue("breg_type_cd");	// 사업자등록구분 값
			var breg_no = $M.getValue("breg_no");	// 주민번호 or 사업자번호 값
			
			// 날짜 범위 체크
			if($M.checkRangeByFieldName("breg_open_dt", "breg_close_dt", true) == false) {
				return;
			};

			if ($M.validation(frm) == false) {
				return;
			};

			// 개인 저장시 업체명 = 대표자명
			if(bregType == "PER") {
				if(breg_no.length != 13) {
					alert("주민번호를 다시 확인해주세요.(13자리)");
					return;
				};
				$M.setValue(frm, "breg_name",  $M.getValue("breg_rep_name"));
			} else {
				if(breg_no.length != 10) {
					alert("사업자번호를 다시 확인해주세요.(10자리)");
					return;
				};
			}
			// validation check
 			if($M.validation(document.main_form, {field:["breg_no", "breg_rep_name", "breg_name"]}) == false) {
				return;
			};
			var breg_seq = $M.getValue("breg_seq");
			$M.goNextPageAjaxSave(this_page + "/", $M.toValueForm(frm), { method : "POST"},
				function(result) {
					if(result.success) {
						if($M.getValue("popup_yn") == "Y") {
							var param = {
									"breg_no" : $M.getValue("breg_no"),
									"breg_name" : $M.getValue("breg_name"),
									"breg_rep_name" : $M.getValue("breg_rep_name"),
									"breg_cor_type" : $M.getValue("breg_cor_type"),
									"breg_cor_part" : $M.getValue("breg_cor_part"),
									"biz_post_no" : $M.getValue("biz_post_no"),
									"biz_addr1" : $M.getValue("biz_addr1"),
									"biz_addr2" : $M.getValue("biz_addr2"),
									"real_breg_no" : $M.getValue("breg_no"),
									"breg_seq" : result.breg_seq,
									"new_yn" : "Y"
							}
							<c:if test="${not empty inputParam.parent_js_name}">
							opener.${inputParam.parent_js_name}(param);
							</c:if>
							window.close();
						} else {
							// 사업자정보 목록 이동
							$M.goNextPage("/cust/cust0105");
						}
					};
				}
			);
		}
		// 등록고객 검색 팝업
		function goMemberPopup() {
			var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=900, left=0, top=0";
			$M.goNextPage('/comp/comp0301', "", {popupStatus : popupOption});
		}
		
		function goSendEmailPopup() {
			var param = {
	     			 'to' : $M.getValue("taxbill_email")
	     	  };
			openSendEmailPanel($M.toGetParam(param));
		}
		
		// 사업장주소 저장
		function setAddrArea(data) {
			var frm = document.main_form;
			$M.setValue(frm, "biz_post_no", data.zipNo);
			$M.setValue(frm, "biz_addr1", data.roadAddrPart1);
			$M.setValue(frm, "biz_addr2", data.addrDetail);
		}
		
		// 사업자주소 저장
		function setAddrPerson(data) {
			var frm = document.main_form;
			$M.setValue(frm, "rep_post_no", data.zipNo);
			$M.setValue(frm, "rep_addr1", data.roadAddrPart1);
			$M.setValue(frm, "rep_addr2", data.addrDetail);
		}
		
		// 고객조회 팝업에서 클릭한 셀값 세팅
		function setCustInfo(row) {
			var frm = document.main_form;
			
			$M.setValue(frm, "cust_name", row.cust_name);
			$M.setValue(frm, "cust_no", row.cust_no);
		}
		
		function fnClose() {
			window.close();
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
</head>
<body>
	<form id="main_form" name="main_form">
		<!-- 고객번호 -->
		<input type="hidden" id="cust_no" name="cust_no">
		<input type="hidden" id="popup_yn" name="popup_yn" value="${inputParam.popup_yn}"> 
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" onclick="fnList();" class="btn btn-outline-light"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<!-- <h2>사업자정보등록</h2> -->
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
				<!-- /상세페이지 타이틀 -->
				<div class="contents">
					<!-- 폼테이블 -->					
					<div>
						<table class="table-border">
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
										<c:forEach items="${codeMap['BREG_TYPE']}" var="bregItem">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="breg_type_cd" value="${bregItem.code_value}" onchange="fnSetBregType('${bregItem.code_value}');" <c:if test="${bregItem.code_value eq 'COR'}">checked="checked"</c:if>>
											<label class="form-check-label">${bregItem.code_name}</label>
										</div>
										</c:forEach>
									</td>	
									<th id="changeBregNo" class="text-right essential-item">사업자번호</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
									<td>
										<input type="text" id="breg_no" name="breg_no" class="form-control essential-bg" datatype="int" minlength="10" maxlength="13" placeholder="-없이 숫자만 입력" alt="사업자번호">
									</td>
									<th class="text-right essential-item">업체명</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
									<td>
										<input type="text" id="breg_name" name="breg_name" class="form-control essential-bg" alt="업체명">
									</td>	
									<th class="text-right essential-item">사용여부</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="use_yn" value="Y" checked="checked">
											<label class="form-check-label">사용</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="use_yn" value="N">
											<label class="form-check-label">사용안함</label>
										</div>
									</td>									
								</tr>
								<tr>
									<th class="text-right essential-item">대표자</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
									<td>
										<input type="text" id="breg_rep_name" name="breg_rep_name" class="form-control essential-bg" alt="대표자">
									</td>	
									<th class="text-right">법인등록번호</th>
									<td>
										<input type="text" id="breg_cor_no" name="breg_cor_no" class="form-control" placeholder="-없이 숫자만 입력" datatype="int" minlength="10" maxlength="13">
									</td>	
									<th class="text-right">업태</th>
									<td>
										<input type="text" id="breg_cor_type" name="breg_cor_type" class="form-control">
									</td>
									<th class="text-right">업종</th>
									<td>
										<input type="text" id="breg_cor_part" name="breg_cor_part" class="form-control">
									</td>											
								</tr>
								<tr>
									<th class="text-right">설립일</th>
									<td>
										<div class="input-group">
											<input type="text" id="breg_open_dt" name="breg_open_dt" class="form-control border-right-0 calDate" dateFormat="yyyy-MM-dd" alt="설립일">
										</div>
									</td>		
									<th class="text-right">폐업일</th>
									<td>
										<div class="input-group">
											<input type="text" id="breg_close_dt" name="breg_close_dt" class="form-control border-right-0 calDate" dateFormat="yyyy-MM-dd" alt="폐업일">
										</div>
									</td>
									<th class="text-right">계산서발행이메일</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-10">
												<input type="text" class="form-control" id="taxbill_email" name="taxbill_email" maxlength="100">
											</div>
											<div class="col-2">
												<button type="button" onclick="javascript:goSendEmailPopup();" class="btn btn-icon btn-primary-gra"><i class="material-iconsmail"></i></button>	
											</div>									
										</div>
									</td>	
									<th class="text-right">등록고객</th>
									<td>
										<div class="input-group">
											<input type="text" id="cust_name" name="cust_name" class="form-control border-right-0" readonly="readonly">
											<button type="button" onclick="javascript:openSearchCustPanel('setCustInfo');" class="btn btn-icon btn-primary-gra" ><i class="material-iconssearch"></i></button>
										</div>
									</td>								
								</tr>
								<tr>
									<th class="text-right essential-item">사업장주소</th>
									<td colspan="3">
										<div class="form-row inline-pd mb7">
											<div class="col-4">
												<input type="text" id="biz_post_no" name="biz_post_no" class="form-control" required="required" alt="사업장 우편번호" readonly="readonly">
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
												<input type="text" id="biz_addr1" name="biz_addr1" class="form-control" required="required" alt="사업장 주소1" readonly="readonly">
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12">
												<input type="text" id="biz_addr2" name="biz_addr2" class="form-control">
											</div>
										</div>
									</td>
									<th class="text-right">사업자주소</th>
									<td colspan="3">
										<div class="form-row inline-pd mb7">
											<div class="col-4">
												<input type="text" id="rep_post_no" name="rep_post_no" class="form-control">
											</div>
											<div class="col-8">
												<button type="button" onclick="javascript:openSearchAddrPanel('setAddrPerson');" class="btn btn-primary-gra">주소찾기</button>
											</div>								
										</div>
										<div class="form-row inline-pd mb7">
											<div class="col-12">
												<input type="text" id="rep_addr1" name="rep_addr1" class="form-control">
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12">
												<input type="text" id="rep_addr2" name="rep_addr2" class="form-control">
											</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">세금계산서안내휴대전화</th>
									<td>
										<input type="text" id="tax_notice_phone_no" name="tax_notice_phone_no" class="form-control" format="phone" minlength=9 maxlength=11>
									</td>
									<th class="text-right">사업장기타사항</th>
									<td>
										<input type="text" id="breg_rep_bigo" name="breg_rep_bigo" class="form-control"  maxlength="1000">
									</td>
									<th class="text-right">비고</th>
									<td colspan="3">
										<input type="text" id="bigo" name="bigo" class="form-control">
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
			<c:if test="${inputParam.popup_yn ne 'Y'}">
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
			</c:if>	
		</div>
		<!-- /contents 전체 영역 -->
	</form>	
</body>
</html>