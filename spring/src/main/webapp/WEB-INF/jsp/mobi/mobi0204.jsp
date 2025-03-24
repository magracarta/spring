<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 모바일관리 > 고객앱관리 > 메뉴내기능관리
-- 작성자 : 정선경
-- 최초 작성일 : 2023-07-11 13:41:39
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;
	var auiGridFnc;
	var maxSeq = 1;
	
	$(document).ready(function() {
		fnInit();
	});

	function fnInit() {
		createAUIGrid();
		createAUIGridFnc();
		fnNew();
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_menu_name", "s_menu_fnc_name", "s_cust_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			}
		});
	}
	
	//조회
	function goSearch() {
		var param = {
			"s_menu_name" : $M.getValue("s_menu_name"),
			"s_menu_fnc_name" : $M.getValue("s_menu_fnc_name"),
			"s_cust_name" : $M.getValue("s_cust_name"),
			"s_c_cust_grade_cd_str" : $M.getValue("s_c_cust_grade_cd"),
			"s_c_cust_grade_cd_yn" : $M.getValue("s_c_cust_grade_cd_yn") == ""? "N" : $M.getValue("s_c_cust_grade_cd_yn")
		};

		$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					fnNew();
					AUIGrid.setGridData(auiGrid, result.list);
					AUIGrid.setGridData(auiGridFnc, []);
				}
			}
		);
	}

	//메뉴 클릭시 클릭시
	function goSearchDetail(menuSeq, menuChk) {
		var param = {
			"c_menu_seq" : menuSeq,
		};
		$M.goNextPageAjax(this_page + "/detail", $M.toGetParam(param),{ method : 'get'},
				function(result) {
					if(result.success){
						maxSeq = result.max_seq;
						if(menuChk != undefined) {
							$M.setValue("menu_fnc_no", "F" + $M.lpad($M.getValue("c_menu_seq"), 5, 0) + "_" + $M.lpad(maxSeq, 3, "0"));
						} else {
							fnNew(menuSeq);
							AUIGrid.setGridData(auiGridFnc, result.menu_fnc_list);
						}
					}
				}
		);
	}

	// 메뉴 기능상세 클릭 시
	function goSearchFncDetail(menuSeq, menuFncNo) {
		var param = {
			"c_menu_seq" : menuSeq,
			"menu_fnc_no" : menuFncNo,
		};
		$M.goNextPageAjax(this_page + "/detail/fnc", $M.toGetParam(param),{ method : 'get'},
				function(result) {
					if(result.success){
						$("#menu_name").attr("disabled", true);
						$("#menu_name").removeClass("essential-bg");
						$M.setValue("menu_name", result.menu_fnc.c_menu_seq);
						$M.setValue(result.menu_fnc);

						if (result.menu_fnc.app_cust_no_str != '') {
							var appCustNoArr = result.menu_fnc.app_cust_no_str.split("^");
							$('#app_cust_no_str').combogrid("setValues", appCustNoArr);
						}

						if (result.menu_fnc.c_cust_grade_cd_str != '') {
							var cCustGradeCdArr = result.menu_fnc.c_cust_grade_cd_str.split("^");
							$('#c_cust_grade_cd_str').combogrid("setValues", cCustGradeCdArr);
						}
					}
				}
		);
	}

	// 신규 메뉴 등록 시 최대값 조회용
	function fnChangeMenu() {
		var menuSeq = $M.getValue("menu_name");
		$M.setValue("c_menu_seq", menuSeq);
		$M.setValue("menu_fnc_no", "");
		if(menuSeq != "") {
			goSearchDetail(menuSeq, 'change');
		}
	}
   
	//저장
	function goSave() {
		if($M.getValue("c_menu_seq") == "") {
			alert("등록할 메뉴를 선택해주세요.");
			return false;
		}

		var frm = document.main_form;
		if($M.validation(frm) == false) {
			return false;
		}
		frm = $M.toValueForm(frm);

		// 콤보그리드 세팅
		$M.setValue(frm, "app_cust_no_str", $M.getValue("app_cust_no_str").replaceAll("#", "^"));
		$M.setValue(frm, "c_cust_grade_cd_str", $M.getValue("c_cust_grade_cd_str").replaceAll("#", "^"));

		// 체크박스 미체크 N으로 세팅
		$M.setValue(frm, "app_cust_yn", $M.getValue("app_cust_yn") == "" ? "N" : "Y");
		$M.setValue(frm, "c_cust_grade_cd_yn", $M.getValue("c_cust_grade_cd_yn") == "" ? "N" : "Y");
		$M.setValue(frm, "use_yn", $M.getValue("use_yn") == "" ? "N" : "Y");

		$M.goNextPageAjaxSave(this_page + "/save", frm, { method : 'POST'},
				function(result) {
					if(result.success) {
						goSearchDetail($M.getValue("c_menu_seq"));
					}
				}
		);
	}
   
	//갱신
	function fnNew(menuSeq) {
		$("#menu_name").attr("disabled", false);
		$("#menu_name").addClass("essential-bg");
		$M.setValue("c_menu_seq", menuSeq != undefined ? menuSeq : $M.getValue("c_menu_seq"));
		$M.setValue("menu_name", menuSeq != undefined ? menuSeq : $M.getValue("c_menu_seq"));
		$M.setValue("cmd", "C");
		var param = {
			"c_menu_seq" : $M.getValue("c_menu_seq"),
			"menu_fnc_no" : $M.getValue("c_menu_seq") == "" ? "" : "F" + $M.lpad($M.getValue("c_menu_seq"), 5, 0) + "_" + $M.lpad(maxSeq, 3, "0"),
			"menu_fnc_name" : "",
			"app_cust_no_str" : "",
			"app_cust_no_op" : "OR",
			"app_cust_yn"  : "",
			"c_cust_grade_cd_str"  : "",
			"c_cust_grade_cd_op"  : "OR",
			"c_cust_grade_cd_yn" : "",
			"use_yn" : "Y",
			"remark" : "",
		};

		$M.setValue(param);
	}
   
	//메인그리드
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
			wrapSelectionMove : false,
			enableFilter :true
		};

		var columnLayout = [
			{
				headerText : "메뉴번호",
				dataField : "c_menu_seq",
				width : "15%",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{ 
				headerText : "메뉴명",
				dataField : "menu_name",
				width : "40%",
				style : "aui-left aui-link",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "기능명",
				dataField : "menu_fnc_name",
				width : "45%",
				style : "aui-left",
				editable : false,
				filter : {
					showIcon : true
				}
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);

		AUIGrid.bind(auiGrid, "cellClick", function(event){
			if (event.headerText == "메뉴명") {
				goSearchDetail(event.item["c_menu_seq"]);
			}
		});
   }

	function createAUIGridFnc() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
			enableFilter : true,
			independentAllCheckBox : true,
			editable : false,
		};

		var columnLayout = [
			{
				dataField : "c_menu_seq",
				visible : false,
			},
			{
				headerText: "기능번호",
				dataField : "menu_fnc_no",
				style : "aui-center aui-link",
				width : "150",
				editable : false,
			},
			{
				headerText : "메뉴기능명",
				dataField : "menu_fnc_name",
				style : "aui-left",
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "사용여부",
				dataField : "use_yn",
				style : "aui-center",
				width : "70",
			},
		];

		auiGridFnc = AUIGrid.create("#auiGridFnc", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridFnc, []);

		AUIGrid.bind(auiGridFnc, "cellClick", function(event){
			if (event.headerText == "기능번호") {
				$M.setValue("cmd", "U");
				goSearchFncDetail(event.item.c_menu_seq, event.item.menu_fnc_no);
			}
		});
	}
	</script>
</head>
<body>
<!-- script -->
<!-- /script -->
<!-- contents 전체 영역 -->
<form id="main_form" name="main_form">
	<input type="hidden" id="cmd" name="cmd" value="C">
	<div class="content-wrap">
		<div class="content-box">
			<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /메인 타이틀 -->
			<div class="contents">
				<!-- 검색영역 -->
				<div class="search-wrap">
					<table class="table">
						<colgroup>
							<col width="60px">
							<col width="250px">
							<col width="60px">
							<col width="250px">
							<col width="60px">
							<col width="150px">
							<col width="70px">
							<col width= 200px">
							<col width="60px">
							<col width="200px">
							<col width="*">
						</colgroup>
						<tbody>
						<tr>
							<th>메뉴명</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_menu_name" name="s_menu_name" class="form-control">
								</div>
							</td>
							<th>기능명</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_menu_fnc_name" name="s_menu_fnc_name" class="form-control">
								</div>
							</td>
							<th>앱고객명</th>
							<td>
								<input type="text" id="s_cust_name" name="s_cust_name" class="form-control">
							</td>
							<th>앱고객등급</th>
							<td>
								<input type="text" style="width : 140px;"
									   id="s_c_cust_grade_cd"
									   name="s_c_cust_grade_cd"
									   easyui="combogrid"
									   header="Y"
									   easyuiname="c_cust_grade_list_1"
									   panelwidth="180"
									   maxheight="300"
									   textfield="code_name"
									   multi="Y"
									   idfield="code_value" />
								<div class="form-check form-check-inline checkline">
									<input class="form-check-input" type="checkbox" id="s_c_cust_grade_cd_yn" name="s_c_cust_grade_cd_yn" value="Y">
									<label class="form-check-label" for="s_c_cust_grade_cd_yn">포함</label>
								</div>
							</td>
							<td>
								<button type="button" onclick="javascript:goSearch();" class="btn btn-important" style="width: 50px;">조회</button>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- /검색영역 -->
				<div class="row">
					<!-- 메뉴목록 -->
					<div class="col-4">
						<div class="title-wrap mt10">
							<h4>메뉴목록</h4>
						</div>
						<div id="auiGrid" style="margin-top: 5px;height: 635px;"></div>
					</div>
					<!-- /메뉴목록 -->
					<!-- 기능목록 -->
					<div class="col-4">
						<div class="title-wrap mt10">
							<h4>기능목록</h4>
						</div>
						<div id="auiGridFnc" style="margin-top: 5px;height: 635px;"></div>
					</div>
					<!-- /기능목록 -->
					<!-- 메뉴정보 -->
					<div class="col-4">
						<div class="title-wrap mt10">
							<h4>기능상세</h4>
						</div>
						<!-- 폼테이블 -->
						<div style="margin-top: 5px;height: 635px;">
							<table class="table-border">
								<colgroup>
									<col width="85px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-center essential-item">메뉴번호</th>
										<td>
											<div class="btn-group">
												<div class="left">
													<input type="text" class="form-control width230px" id="c_menu_seq" name="c_menu_seq" alt="메뉴번호" readonly>
												</div>
												<div class="right">
													<div class="form-check form-check-inline checkline">
														<input class="form-check-input" type="checkbox" id="use_yn" name="use_yn" value="Y">
														<label class="form-check-label" for="use_yn">사용여부</label>
													</div>
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-center essential-item">메뉴명</th>
										<td>
											<select id="menu_name" name="menu_name" class="form-control essential-bg width280px" style="height:24px; max-width: 280px;" onchange="fnChangeMenu()">
												<option value="">- 선택 -</option>
												<c:forEach items="${menu_list}" var="item">
													<option value="${item.c_menu_seq}">${item.path_menu_name}</option>
												</c:forEach>
											</select>
										</td>
									</tr>
									<tr>
										<th class="text-center essential-item">기능번호</th>
										<td>
											<input type="text" id="menu_fnc_no" name="menu_fnc_no" class="form-control width230px" alt="URL" readonly>
										</td>
									</tr>
									<tr>
										<th class="text-center essential-item">기능명</th>
										<td>
											<input type="text" id="menu_fnc_name" name="menu_fnc_name" class="form-control essential-bg width230px" required="required">
										</td>
									</tr>
									<tr style="height: 140px;">
										<th class="text-center">비고</th>
										<td>
											<textarea style="height: 100%;" id="remark" name="remark" alt="비고">${item.remark}</textarea>
										</td>
									</tr>
									<tr>
										<th class="text-center">앱고객</th>
										<td>
											<c:if test="${not empty app_cust_list}">
												<input type="text" style="width : 180px;"
													   id="app_cust_no_str"
													   name="app_cust_no_str"
													   easyui="combogrid"
													   header="Y"
													   easyuiname="app_cust_list"
													   panelwidth="180"
													   maxheight="300"
													   textfield="cust_name"
													   multi="Y"
													   idfield="app_cust_no" />
												<div class="form-check form-check-inline checkline">
													<input class="form-check-input" type="checkbox" id="app_cust_yn" name="app_cust_yn" value="Y">
													<label class="form-check-label" for="app_cust_yn">포함</label>
												</div>
												<div style="float: right">
													<div class="form-check form-check-inline">
														<input class="form-check-input" type="radio" id="app_cust_no_op_and" name="app_cust_no_op" value="AND" required="required" alt="고객조건연산">
														<label class="form-check-label" for="app_cust_no_op_and">AND</label>
													</div>
													<div class="form-check form-check-inline">
														<input class="form-check-input" type="radio" id="app_cust_no_op_or" name="app_cust_no_op" value="OR" checked="checked" required="required" alt="고객조건연산">
														<label class="form-check-label" for="app_cust_no_op_or">OR</label>
													</div>
												</div>
											</c:if>
										</td>
									</tr>
									<tr>
										<th class="text-center">앱고객 등급</th>
										<td>
											<c:if test="${not empty c_cust_grade_list}">
												<input type="text" style="width : 180px;"
													   id="c_cust_grade_cd_str"
													   name="c_cust_grade_cd_str"
													   easyui="combogrid"
													   header="Y"
													   easyuiname="c_cust_grade_list_2"
													   panelwidth="180"
													   maxheight="300"
													   textfield="code_name"
													   multi="Y"
													   idfield="code_value" />
												<div class="form-check form-check-inline checkline">
													<input class="form-check-input" type="checkbox" id="c_cust_grade_cd_yn" name="c_cust_grade_cd_yn" value="Y">
													<label class="form-check-label" for="c_cust_grade_cd_yn">포함</label>
												</div>
												<div style="float: right">
													<div class="form-check form-check-inline">
														<input class="form-check-input" type="radio" id="c_cust_grade_cd_op_and" name="c_cust_grade_cd_op" value="AND" required="required" alt="자동등급조건연산">
														<label class="form-check-label" for="c_cust_grade_cd_op_and">AND</label>
													</div>
													<div class="form-check form-check-inline">
														<input class="form-check-input" type="radio" id="c_cust_grade_cd_op_or" name="c_cust_grade_cd_op" value="OR" checked="checked" required="required" alt="자동등급조건연산">
														<label class="form-check-label" for="c_cust_grade_cd_op_or">OR</label>
													</div>
												</div>
											</c:if>
										</td>
									</tr>
								</tbody>
							</table>
							<div class="btn-group mt5">
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
								</div>
							</div>
						</div>
						<!-- /폼테이블 -->
					</div>
					<!-- /메뉴정보 -->
				</div>
			</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
<!-- /contents 전체 영역 -->
</form>
</body>
</html>