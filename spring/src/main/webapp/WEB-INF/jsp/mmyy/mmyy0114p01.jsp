<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무접수현황 > 업무접수현황 등록 > null
-- 작성자 : 박동훈
-- 최초 작성일 : 2024-12-06 12:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/static/js/qrcode.min.js"></script>
</head>
<script type="text/javascript">
	$(document).ready(function() {

		$("button[name='__mem_search_btn']").prop("disabled",true);
		$("#s_web_id").prop("disabled",true);
		$("#btnRentalMachineInfo").addClass("dpn");

		setRepairTime();

		$("input[name='self_assign_type_cd']").change(function(){
			if ($('input[name=self_assign_type_cd]:checked').val() == ("02")) {
				$("#reserve_repair_st_ti").prop("disabled",true);
				$("#reserve_repair_ed_ti").prop("disabled",true);
				$M.setValue("reserve_repair_st_ti",null);
				$M.setValue("reserve_repair_ed_ti",null);
				$("#selectMachineBtn").prop("disabled",true);
				$M.setValue("__s_machine_seq",null);
				$M.setValue("machine_seq",null);
				$M.setValue("body_no",null);
				$M.setValue("machine_name",null);
				$("#btnRentalMachineInfo").removeClass("dpn");
				$("#in_dt").prop("disabled",true);
				$M.setValue("in_dt",null);
			}else {
				$("#reserve_repair_st_ti").prop("disabled",false);
				$("#reserve_repair_ed_ti").prop("disabled",false);
				$("#selectMachineBtn").prop("disabled",false);
				$("#btnRentalMachineInfo").addClass("dpn");
				$("#in_dt").prop("disabled",false);
				setRepairTime();
			}
		});

		if("${inputParam.s_cust_no}" != ""){
			var param = {
				"cust_no" : "${inputParam.s_cust_no}"
			};
			fnSetCustInfo(param);
		}

	});

	function setRepairTime(){
		var nowT = $M.getCurrentDate("HH");
		var nowM = $M.toNum($M.getCurrentDate("mm"));

		if(nowM <= 30) {
			$M.setValue("reserve_repair_st_ti", nowT + "30");
			$M.setValue("reserve_repair_ed_ti", nowT + "30");
		} else {
			$M.setValue("reserve_repair_st_ti", $M.lpad($M.toNum(nowT)+1, 2, "0") + "00");
			$M.setValue("reserve_repair_ed_ti", $M.lpad($M.toNum(nowT)+1, 2, "0") + "00");
		}
	}

	//차대번호 조회
	function selectMachineSeq(){
		var param = {
			"s_cust_name" : $M.getValue("cust_name"),
			"s_hp_no" : $M.getValue("hp_no"),
		};
		openSearchDeviceHisPanel('fnSetInformation',$M.toGetParam(param));
	}

	function fnSetInformation(data) {
		fnSetInformation(data, 'N');
	}

	// 차대번호, 차주명 조회
	function fnSetInformation(data, initYn) {

		var custNo = data.cust_no;
		if(custNo == "" || custNo == null) {
// 				alert("고객이 등록되어 있지 않은 장비입니다.\n고객을 먼저 등록해주세요.");
// 				return;
			custNo = "20060727140532287";
		}

		var param = {
			"s_machine_seq" : data.machine_seq,
			"s_cust_no" : custNo
		};

		$M.goNextPageAjax("/serv/serv010101/search", $M.toGetParam(param), {method : 'GET'},
				function (result) {
					if(result.success) {
						dataSetting(result, initYn);
					}
				}
		);
	}

	// 장비, 고객 정보 Setting
	function dataSetting(result, initYn) {
		var item = result.custBean;
		var jobReposrtNo = result.machineBean.before_job_report_no;
		var custGradeHandCdStr = item.cust_grade_hand_cd_str;

		$M.setValue("cust_grade_hand_cd_str", custGradeHandCdStr);
		if (custGradeHandCdStr.indexOf("03") != -1) {
			alert("거래금지 고객입니다. 확인후 진행해주세요.");
			return false;
		}
		if (custGradeHandCdStr.indexOf("04") != -1) {
			alert("그레이장비 보유 고객입니다. 정비전에 확인 바랍니다.");
		}
		// 21.08.03 (SR:12096) 미수금이있거나, 외상매출금지고객에 문구 알림 추가. - 황빛찬
		// 21.08.04 (SR:12145) YK렌탈장비는 알림 제외 추가 - 황빛찬
		if (item.cust_no != "20130603145119670" && (item.deal_gubun_cd == "9" || item.misu_amt > 0)) {
			alert("외상매출금지(미수고객)입니다. 정비전에 확인 바랍니다.");
		}

		if(jobReposrtNo != "") {
			alert("해당 차대번호(" + result.machineBean.body_no + ")로\n[" + jobReposrtNo + "]정비지시서가\n미완료 상태입니다. \n해당 정비지시서를 먼저 완료해주세요.");
			return false;
		}

		// 장비관련
		$M.setValue(result.machineBean);
		$M.setValue("__s_machine_seq", result.machineBean.machine_seq);

		// 고객정보
		$M.setValue(result.custBean);
	}

	// 고객조회 결과 - 견적서 관리에서 등록할 경우 정보를 불러옴
	function fnSetCustInfo(row) {
		console.log(row);
		$M.goNextPageAjax("/rent/custInfo/"+row.cust_no, "", {method : 'GET'},
				function(result) {
					if(result.success) {
						var custGradeHandCdStr = result.cust_grade_hand_cd_str;
						$M.setValue("cust_grade_hand_cd_str", custGradeHandCdStr);
						if (custGradeHandCdStr.indexOf("03") != -1) {
							alert("거래금지 고객입니다. 확인후 진행해주세요.");
							return false;
						}
						if (custGradeHandCdStr.indexOf("04") != -1) {
							alert("그레이장비 보유 고객입니다. 렌탈신청 전에 확인 바랍니다.");
						}

						var param = {
							hp_no : $M.phoneFormat(result.hp_no),
							cust_no : result.cust_no,
							cust_name : result.cust_name,
							body_no : '',
							machine_seq : '',
							machine_name : '',
							__s_machine_seq : '',
						}
						$M.setValue(param);

						//고객 선택시 차대번호 셋팅
						if(row.machine_seq != undefined && row.machine_seq != "" && $M.getValue("self_assign_type_cd") == "01"){
							fnSetInformation(row,'N');
						}
						goSearchPrivacyAgree();
					}
				}
		);
	}

	// 개인정보동의 팝업
	function goSearchPrivacyAgree() {
		var param = {
			cust_no: $M.getValue("cust_no")
		}
		$M.goNextPageAjax("/comp/comp0306/search", $M.toGetParam(param), {method: 'get'},
				function (result) {
					if (result.success) {
						var custInfo = result.custInfo;
						if (custInfo.personal_yn != "Y") {
							if (confirm("개인정보 동의사항을 확인하세요") == true) {
								openPrivacyAgreePanel('fnSetPrivacy', $M.toGetParam(param));
							}
						}
					}
				}
		);
	}



	// 저장
	function goSave() {
		var frm = document.main_form;
		//validationcheck
		if($M.validation(frm, {field:["cust_no", "org_code","consult_text"]})==false) {return;};

		if($M.getValue("self_assign_type_cd") == ""){ alert("접수 분류를 선택해주세요."); return false;}
		$M.setValue("self_assign_dt",$M.getCurrentDate("yyyyMMdd"));
		frm = $M.toValueForm(document.main_form);
		var msg = "저장하시겠습니까?";
		$M.goNextPageAjaxMsg(msg, this_page + "/save", frm, {method: 'POST'},
				function (result) {
					if (result.success) {
						$M.setValue("self_assign_no", result.self_assign_no);
						$M.setValue("reg_dt", $M.getCurrentDate("yyyy년 MM월 dd일 / HH:mm"));
						alert("저장이 완료되었습니다.");
						var params = {
							"s_self_assign_no": result.self_assign_no
						};
						var popupOption = "";
						$M.goNextPage('/mmyy/mmyy0114p02', $M.toGetParam(params), {popupStatus: popupOption});
						window.opener.goSearch();
						window.close();
					}
				}
		);
	}
	function fnCancel() {
		window.close();
	}

	// 배정직원 Setting
	function goPick() {
		if(confirm("찜 하시겠습니까?")){
			$M.setValue("assign_mem_no", "${SecureUser.mem_no}");
			$M.setValue("assign_name", "${SecureUser.user_name}");
			$M.setValue("assign_date", $M.getCurrentDate("yyyy-MM-dd HH:mm:ss"))
		}
	}

	// 3-5차 렌탈가능장비조회 팝업 호출 (ERP > 렌탈 > 렌탈신청현황 조회 메뉴 팝업으로 호출)
	function fnRentalMachineList() {
		if ($M.getValue("self_assign_type_cd") == '02') {
			$M.goNextPage('/rent/rent0101', $M.toGetParam({}), {popupStatus : ""});
		} else {
			alert("렌탈건만 확인 가능합니다.");
		}
	}

</script>
<body>
<form id="main_form" name="main_form">
<input type="hidden" name="reg_id" id="reg_id" value="${SecureUser.mem_no}">
<input type="hidden" name="org_code" id="org_code" value="${SecureUser.org_code}">
<input type="hidden" name="self_assign_org_code" id="self_assign_org_code" value="${SecureUser.org_code}">
<input type="hidden" name="self_assign_dt" id="self_assign_dt" value="">
<input type="hidden" name="assign_mem_no" id="assign_mem_no">
<input type="hidden" name="assign_date" id="assign_date">
<input type="hidden" name="complete_date" id="complete_date">
<input type="hidden" id="page_type" name="page_type" value="JOB_REPORT">
<input type="hidden" id="s_job_report_no" name="s_job_report_no">
<input type="hidden" id="s_as_no" name="s_as_no">
<input type="hidden" id="s_rental_doc_no" name="s_rental_doc_no">
<input type="hidden" id="machine_seq" name="machine_seq">
<input type="hidden" id="cust_grade_hand_cd_str" name="cust_grade_hand_cd_str"> <%--거래 금지 고객--%>

	<div class="popup-wrap width-100per">
		<!-- 상세페이지 타이틀 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /상세페이지 타이틀 -->
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div>
				<div class="title-wrap">
					<div class="left text-warning">
						${sar_error_msg }
					</div>
					<div class="right half-print">
						<div class="form-row inline-pd pr">
							<div class="col-auto" id="qr_image" name="qr_image">
								<input type="hidden" id="qr_no" name="qr_no">
							</div>
							<%--<span class="condition-item mr5">상태 : 작성중</span>--%>
							<div class="col-auto">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
				</div>
				<div class="row mt10">
					<!-- 1. 장비정보 -->
					<div class="col-6">
						<table class="table-border mt5">
							<colgroup>
								<col width="100px">
								<col width="200px">
								<col width="100px">
								<col width="230px">
								<col width="100px">
								<col width="200px">
							</colgroup>
							<tbody>
							<tr>
								<th class="text-right">접수번호</th>
								<td>
									<input type="text" id="self_assign_no" name="self_assign_no" class="form-control" readonly="readonly">
								</td>
								<th class="text-right">접수일시</th>
								<td>
									<input type="text" id="reg_dt" name="reg_dt" class="form-control" readonly="readonly">
								</td>
								<th class="text-right">접수센터</th>
								<td>
									<input type="text" id="org_name" name="org_name" class="form-control" readonly="readonly" required="required" alt="센터" value="${SecureUser.org_name}">
								</td>
							</tr>
							<tr>
								<th class="text-right">접수구분</th>
								<td>
									<input type="text" class="form-control" name="reg_div" id="reg_div" readonly="readonly" value="ERP">
								</td>
								<th class="text-right essential-item">접수분류</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="self_assign_type_cd_1" name="self_assign_type_cd" checked value="01"  >
										<label for="self_assign_type_cd_1" class="form-check-label">정비</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="self_assign_type_cd_2" name="self_assign_type_cd" value="02"  >
										<label  for="self_assign_type_cd_2"  class="form-check-label">렌탈계약</label>
									</div>
								</td>
								<th class="text-right">정비구분</th>
								<td>
									<input type="text" class="form-control" name="job_type_name" id="job_type_name" readonly="readonly" value="">
								</td>
							</tr>
							<tr>
								<th class="text-right">접수자</th>
								<td>
									<input type="text" class="form-control" name="reg_name" id="reg_name" readonly="readonly" value="${SecureUser.user_name}">
								</td>
								<th class="text-right rs essential-item">고객명</th>
								<td>
									<div class="row">
										<div class="col-auto">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 width100px" id="cust_name" name="cust_name" readonly="readonly" required="required" alt="고객명" value="">
												<input type="hidden" id="cust_no" name="cust_no" value="" alt="고객명">
												<button type="button" class="btn btn-icon btn-primary-gra"  onclick="javascript:openSearchCustPanel('fnSetCustInfo');" id="_goSearchCust" name="_goSearchCust"><i class="material-iconssearch" ></i></button>
												&nbsp;&nbsp;<button type="button" class="btn btn-primary-gra" id="btnRentalMachineInfo" name="btnRentalMachineInfo" onclick="javascript:fnRentalMachineList();">렌탈가능장비</button>
											</div>
										</div>
									</div>
								</td>
								<th class="text-right">연락처</th>
								<td>
									<input type="text" class="form-control" readonly="readonly" id="hp_no" name="hp_no" value="" format="tel">
								</td>
							</tr>
							<tr>
								<th class="text-right">배정자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-7">
											<input type="text" class="form-control" id="assign_name" name="assign_name" readonly="readonly">
										</div>
										<div class="col-3 text-right">
											<button type="button" class="btn btn-primary-gra" onclick="javascript:goPick();">찜하기</button>
										</div>
									</div>
								</td>
								<th class="text-right">차대번호</th>
								<td>
									<div class="form-row inline-pd pr">
										<div class="col-8">
											<div class="input-group">
												<input type="text" id="body_no" name="body_no" class="form-control border-right-0 essential-bg" value="" readonly="readonly" required="required" alt="차대번호">
												<button type="button" class="btn btn-icon btn-primary-gra" id="selectMachineBtn" onclick="javascript:selectMachineSeq();" ><i class="material-iconssearch"></i></button>
											</div>
										</div>
										<div class="col-4">
											<jsp:include page="/WEB-INF/jsp/common/commonMachineJob.jsp">
												<jsp:param name="li_machine_type" value="__machine_detail#__repair_history#__as_todo#__campaign#__work_db"/>
											</jsp:include>
										</div>
									</div>
								</td>
								<th class="text-right">모델명</th>
								<td>
									<input type="text" class="form-control" id="machine_name" name="machine_name" value="" readonly="readonly">
								</td>
							</tr>
							<tr>
								<th class="text-right">배정 이관</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-auto">
											<jsp:include page="/WEB-INF/jsp/common/searchMem.jsp">
												<jsp:param name="required_field" value=""/>
												<jsp:param name="s_org_code" value=""/>
												<jsp:param name="s_work_status_cd" value=""/>
												<jsp:param name="readonly_field" value=""/>
												<jsp:param name="execFuncName" value="setMemberOrgMapPanel"/>
											</jsp:include>
										</div>
									</div>
								</td>
								<th class="text-right">입고일자</th>
								<td>
									<div class="input-group width160px">
										<input type="text" class="form-control border-right-0 calDate" id="in_dt" name="in_dt" dateFormat="yyyy-MM-dd" value="">
									</div>
								</td>
								<th class="text-right">정비예약시간</th>
								<td>
									<div class="form-row">
										<div class="col-4">
											<select class="form-control" id="reserve_repair_st_ti" name="reserve_repair_st_ti">
												<c:forEach var="hr" varStatus="i" begin="6" end="23" step="1">
													<c:forEach var="min" varStatus="j" begin="0" end="1">
														<option value="<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/><c:out value="${min eq 0 ? '00' : '30'}"/>">
															<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/>:<c:out value="${min eq 0 ? '00' : '30'}"/>
														</option>
													</c:forEach>
												</c:forEach>
											</select>
										</div>
										~
										<div class="col-4">
											<select class="form-control" id="reserve_repair_ed_ti" name="reserve_repair_ed_ti">
												<c:forEach var="hr" varStatus="i" begin="6" end="23" step="1">
													<c:forEach var="min" varStatus="j" begin="0" end="1">
														<option value="<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/><c:out value="${min eq 0 ? '00' : '30'}"/>">
															<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/>:<c:out value="${min eq 0 ? '00' : '30'}"/>
														</option>
													</c:forEach>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>

							</tr>
							<tr>
								<th class="text-right">상태</th>
								<td colspan="5">
									<input type="text" class="form-control" readonly="readonly" placeholder="미 배정">
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">접수 내용</th>
								<td colspan="5">
									<textarea class="form-control" style="height: 100px;" id="consult_text" name="consult_text" alt="접수내용"></textarea>
								</td>
							</tr>
							<tr>
								<th class="text-right">처리 일시</th>
								<td>
									<input type="text" id="complete_dt" name="complete_dt" class="form-control" readonly="readonly">
								</td>
								<th class="text-right">지시서(계약서)</th>
								<td>
								</td>
								<th class="text-right">서비스 일지</th>
								<td>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /1. 장비정보 -->
				<!-- /상단 폼테이블 -->
			</div>
			<!-- 하단 폼테이블 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>
