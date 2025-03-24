<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비대장관리 > 장비신규등록 > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-05-21 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
<script type="text/javascript">
	$(document).ready(function() {
	});

	function goSave() {
		var frm = document.main_form;
		//validationcheck
		if($M.validation(frm,
				{field:["machine_name", "body_no", "cust_name", "cust_no", "in_org_code", "in_org_name"]})==false) {
			return;
		};

		$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm), {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("저장이 완료되었습니다.");
						$M.goNextPage("/sale/sale0205");
					}
				}
		);
	}

	function fnList() {
		history.back();
	}

	// 고객정보 Setting
	function setCustInfo(data) {
		// alert(JSON.stringify(data));
		$M.setValue("breg_no", data.breg_no);
		$M.setValue("breg_name", data.breg_name);
		$M.setValue("hp_no", data.real_hp_no);
		$M.setValue("___cust_name", data.real_cust_name);
		$M.setValue("cust_name", data.real_cust_name);
		$M.setValue("cust_no", data.cust_no);
	}

	// 장비정보 Setting
	function setModelInfo(data) {
		// alert(JSON.stringify(data));
		$M.setValue("machine_name", data.machine_name);
		$M.setValue("machine_plant_seq", data.machine_plant_seq);
		$M.setValue("engine_model_1", data.motor_type);
		$M.setValue("engine_model_2", data.motor_type_2);
	}

	// 입고센터 Setting
	function setOrgMapCenterPanel(data) {
		// alert(JSON.stringify(data));
		$M.setValue("in_org_code", data.org_code);
		$M.setValue("in_org_name", data.org_name);
	}

	function setSendSMSInfo(row) {
		alert(JSON.stringify(row));
	}
	  
	// 문자발송
	function fnSendSms() {
		var param = {
			"name" : $M.getValue("cust_name"),
			"hp_no" : $M.getValue("hp_no")
		};

		openSendSmsPanel($M.toGetParam(param));
	}
	
	// 업무DB 연결 함수 21-08-06이강원
 	function openWorkDB(){
 		openWorkDBPanel('',$M.getValue("machine_plant_seq"));
 	}
</script>
</head>
<body>
	<form id="main_form" name="main_form">
		<input type="hidden" id="___cust_name" name="___cust_name">
		<input type="hidden" id="machine_out_ye" name="machine_out_ye" value="E">
		<input type="hidden" id="mch_type_cad" name="mch_type_cad" value="D">
		<div class="layout-box">
			<!-- contents 전체 영역 -->
			<div class="content-wrap">
				<div class="content-box">
					<!-- 상세페이지 타이틀 -->
					<div class="main-title detail">
						<div class="detail-left">
							<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
							<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
						</div>
					</div>
					<!-- /상세페이지 타이틀 -->
					<div class="contents">
						<!-- 상단 폼테이블 -->
						<div>
							<table class="table-border mt5">
								<colgroup>
									<col width="100px">
									<col width="">
									<col width="100px">
									<col width="">
									<col width="100px">
									<col width="">
									<col width="100px">
									<col width="">
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right essential-item">장비모델</th>
										<td>
											<div class="form-row inline-pd pr">
												<div class="col-auto">
													<div class="input-group">
														<input type="text" id="machine_name" name="machine_name" class="form-control border-right-0 width120px essential-bg" readonly="readonly" required="required" alt="장비모델">
														<input type="hidden" id="machine_plant_seq" name="machine_plant_seq">
														<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchModelPanel('setModelInfo', 'N');"><i class="material-iconssearch"></i></button>
													</div>
												</div>
												<div class="col-auto">
							                        <button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
										        </div>
											</div>
										</td>
										<th class="text-right">엔진모델1</th>
										<td>
											<input type="text" name="engine_model_1" id="engine_model_1" class="form-control">
										</td>
										<th class="text-right">연식</th>
										<td>
											<select class="form-control width80px" id="made_year" name="made_year">
												<c:forEach var="i" begin="1990" end="${inputParam.s_current_year}" step="1">
													<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
													<option value="${year_option}" <c:if test="${year_option eq inputParam.s_current_year}">selected</c:if>>${year_option}년</option>
												</c:forEach>
											</select>
										</td>
<%--										<th class="text-right">엔진모델2</th>--%>
<%--										<td>--%>
<%--											<input type="text" name="engine_model_2" id="engine_model_2" class="form-control">--%>
<%--										</td>--%>
										<th class="text-right">옵션모델1</th>
										<td>
											<input type="text" id="opt_model_1" name="opt_model_1" class="form-control">
										</td>
										<th class="text-right">옵션모델2</th>
										<td>
											<input type="text" name="opt_model_2" id="opt_model_2" class="form-control">
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">차대번호</th>
										<td>
											<input type="text" name="body_no" id="body_no" required="required" class="form-control width145px essential-bg" alt="차대번호">
										</td>
										<th class="text-right">엔진번호1</th>
										<td>
											<input type="text" name="engine_no_1" id="engine_no_1" class="form-control">
										</td>
										<th class="text-right"></th>
										<td></td>
<%--										<th class="text-right">엔진번호2</th>--%>
<%--										<td>--%>
<%--											<input type="text" name="engine_no_2" id="engine_no_2" class="form-control">--%>
<%--										</td>--%>
										<th class="text-right">옵션번호1</th>
										<td>
											<input type="text" name="opt_no_1" id="opt_no_1" class="form-control">
										</td>
										<th class="text-right">옵션번호2</th>
										<td>
											<input type="text" name="opt_no_2" id="opt_no_2" class="form-control">
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">차주명</th>
										<td>
											<div class="form-row inline-pd pr">
												<div class="col-auto">
													<div class="input-group">
														<input type="text" id="cust_name" name="cust_name" class="form-control border-right-0 width120px essential-bg" readonly="readonly" required="required" alt="차주명">
														<input type="hidden" id="cust_no" name="cust_no">
														<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('setCustInfo');"><i class="material-iconssearch"></i></button>
													</div>
												</div>
											</div>
										</td>
										<th class="text-right">휴대폰</th>
										<td>
											<div class="input-group">
												<input type="text" name="hp_no" id="hp_no" class="form-control border-right-0 width100px" format="phone" maxlength="11" readonly="readonly">
												<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
											</div>
										</td>
										<th class="text-right">업체명</th>
										<td>
											<input type="text" name="breg_name" id="breg_name" class="form-control" readonly="readonly">
										</td>
										<th class="text-right">장비기사명</th>
										<td>
											<input type="text" name="driver_name" id="driver_name" class="form-control width145px">
										</td>
										<th class="text-right">정비기사휴대폰</th>
										<td>
											<div class="input-group">
												<input type="text" name="driver_hp_no" id="driver_hp_no" format="phone" maxlength="11" class="form-control border-right-0 width100px">
												<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">입고일</th>
										<td>
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="in_dt" name="in_dt" dateformat="yyyy-MM-dd" readonly="readonly">
											</div>
										</td>
										<th class="text-right">출하일</th>
										<td>
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="out_dt" name="out_dt" dateformat="yyyy-MM-dd" readonly="readonly">
											</div>
										</td>
										<th class="text-right">출하구분</th>
										<td>
											<select id="machine_status_cd" name="machine_status_cd" class="form-control width120px">
												<option value="">- 선택 -</option>
												<c:forEach items="${codeMap['MACHINE_STATUS']}" var="item">
													<option value="${item.code_value}" ${item.code_value == list.machine_status_cd ? 'selected="selected"' : ''}>${item.code_name}</option>
												</c:forEach>
											</select>
										</td>
										<th class="text-right essential-item">입고센터</th>
										<td colspan="3">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 width120px" name="in_org_name" id="in_org_name" required="required" readonly="readonly" alt="입고센터">
												<input type="hidden" name="in_org_code" id="in_org_code">
												<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openOrgMapPanel('setOrgMapCenterPanel');"><i class="material-iconssearch"></i></button>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">판매일</th>
										<td>
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="sale_dt" name="sale_dt" dateformat="yyyy-MM-dd">
											</div>
										</td>
										<th class="text-right">비고</th>
										<td colspan="7">
											<div class="input-group">
												<input type="text" name="note_txt" id="note_txt" class="form-control">
											</div>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
						<!-- /상단 폼테이블 -->
						<!-- 그리드 서머리, 컨트롤 영역 -->
						<div class="btn-group mt5">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
							</div>
						</div>
						<!-- /그리드 서머리, 컨트롤 영역 -->
					</div>
				</div>
				<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
			</div>
			<!-- /contents 전체 영역 -->
		</div>
	</form>
</body>
</html>