<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 메뉴내기능 > null > null
-- 작성자 : 이강원
-- 최초 작성일 : 2022-12-27 17:10:48
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
		createAUIGrid();
		createAUIGridFnc();
		fnNew();
	});
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_menu_name", "s_menu_fnc_name", "s_mem_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
	}
	
	//조회
	function goSearch() {
		var param = {
			"s_menu_name" : $M.getValue("s_menu_name"),
			"s_menu_fnc_name" : $M.getValue("s_menu_fnc_name"),
			"s_mem_name" : $M.getValue("s_mem_name"),
			"s_grade_cd_str" : $M.getValue("s_grade_cd"),
			"s_grade_cd_yn" : $M.getValue("s_grade_cd_yn"),
			"s_job_cd_str" : $M.getValue("s_job_cd"),
			"s_job_cd_yn" : $M.getValue("s_job_cd_yn"),
			"s_org_code" : $M.getValue("s_org_code"),
			"s_org_sub_yn" : $M.getValue("s_org_sub_yn"),
			"s_org_code_yn" : $M.getValue("s_org_code_yn"),
			"s_org_gubun_cd_str" : $M.getValue("s_org_gubun_cd"),
			"s_org_gubun_yn" : $M.getValue("s_org_gubun_yn"),
			"s_org_auth_str" : $M.getValue("s_org_auth"),
			"s_org_auth_yn" : $M.getValue("s_org_auth_yn"),
			"s_job_auth_str" : $M.getValue("s_job_auth_cd"),
			"s_job_auth_yn" : $M.getValue("s_job_auth_yn"),
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
			"menu_seq" : menuSeq,
		};
		$M.goNextPageAjax(this_page + "/detail", $M.toGetParam(param),{ method : 'get'},
				function(result) {
					if(result.success){
						maxSeq = result.maxSeq;
						if(menuChk != undefined) {
							$M.setValue("menu_fnc_no", "F" + $M.lpad($M.getValue("menu_seq"), 5, 0) + "_" + $M.lpad(maxSeq, 3, "0"));
						} else {
							fnNew(menuSeq);
							AUIGrid.setGridData(auiGridFnc, result.menuFncList);
						}
					}
				}
		);
	}

	// 메뉴 기능상세 클릭 시
	function goSearchFncDetail(menuSeq, menuFncNo) {
		var param = {
			"menu_seq" : menuSeq,
			"menu_fnc_no" : menuFncNo,
		};
		$M.goNextPageAjax(this_page + "/detail/fnc", $M.toGetParam(param),{ method : 'get'},
				function(result) {
					if(result.success){
						$("#menu_name").attr("disabled", true);
						$("#menu_name").removeClass("essential-bg");
						$M.setValue("menu_name", result.menuFnc.menu_seq);
						$M.setValue(result.menuFnc);

						var memNoArr = result.menuFnc.mem_no_str.split("^");
						$('#mem_no_str').combogrid("setValues", memNoArr);

						var gradeCdArr = result.menuFnc.grade_cd_str.split("^");
						$('#grade_cd_str').combogrid("setValues", gradeCdArr);

						var jobCdArr = result.menuFnc.job_cd_str.split("^");
						$('#job_cd_str').combogrid("setValues", jobCdArr);

						var orgCodeArr = result.menuFnc.org_code_str.split("^");
						$('#org_code_str').combogrid("setValues", orgCodeArr);

						var orgAuthArr = result.menuFnc.org_auth_str.split("^");
						$('#org_auth_str').combogrid("setValues", orgAuthArr);

						var jobAuthCdArr = result.menuFnc.job_auth_cd_str.split("^");
						$('#job_auth_cd_str').combogrid("setValues", jobAuthCdArr);

						var orgGubunCdArr = result.menuFnc.org_gubun_cd_str.split("^");
						$('#org_gubun_cd_str').combogrid("setValues", orgGubunCdArr);
					}
				}
		);
	}

	// 신규 메뉴 등록 시 최대값 조회용
	function fnChangeMenu() {
		var menuSeq = $M.getValue("menu_name");
		$M.setValue("menu_seq", menuSeq);
		$M.setValue("menu_fnc_no", "");
		if(menuSeq != "") {
			goSearchDetail(menuSeq, 'change');
		}
	}
   
	//저장
	function goSave() {
		if($M.getValue("menu_seq") == "") {
			alert("등록할 메뉴를 선택해주세요.");
			return false;
		}

		var frm = document.main_form;

		if($M.validation(frm) == false) {
			return false;
		}

		frm = $M.toValueForm(frm);

		// 콤보그리드 세팅
		$M.setValue(frm, "mem_no_str", $M.getValue("mem_no_str").replaceAll("#", "^"));
		$M.setValue(frm, "grade_cd_str", $M.getValue("grade_cd_str").replaceAll("#", "^"));
		$M.setValue(frm, "job_cd_str", $M.getValue("job_cd_str").replaceAll("#", "^"));
		$M.setValue(frm, "org_code_str", $M.getValue("org_code_str").replaceAll("#", "^"));
		$M.setValue(frm, "org_auth_str", $M.getValue("org_auth_str").replaceAll("#", "^"));
		$M.setValue(frm, "job_auth_cd_str", $M.getValue("job_auth_cd_str").replaceAll("#", "^"));
		$M.setValue(frm, "org_gubun_cd_str", $M.getValue("org_gubun_cd_str").replaceAll("#", "^"));

		// 체크박스 미체크 N으로 세팅
		$M.setValue(frm, "mem_no_yn", $M.getValue("mem_no_yn") == "" ? "N" : "Y");
		$M.setValue(frm, "grade_cd_yn", $M.getValue("grade_cd_yn") == "" ? "N" : "Y");
		$M.setValue(frm, "job_cd_yn", $M.getValue("job_cd_yn") == "" ? "N" : "Y");
		$M.setValue(frm, "org_sub_yn", $M.getValue("org_sub_yn") == "" ? "N" : "Y");
		$M.setValue(frm, "org_code_yn", $M.getValue("org_code_yn") == "" ? "N" : "Y");
		$M.setValue(frm, "org_auth_yn", $M.getValue("org_auth_yn") == "" ? "N" : "Y");
		$M.setValue(frm, "job_auth_yn", $M.getValue("job_auth_yn") == "" ? "N" : "Y");
		$M.setValue(frm, "org_gubun_yn", $M.getValue("org_gubun_yn") == "" ? "N" : "Y");
		$M.setValue(frm, "use_yn", $M.getValue("use_yn") == "" ? "N" : "Y");

		$M.goNextPageAjaxSave(this_page + "/save", frm, { method : 'POST'},
				function(result) {
					if(result.success) {
						goSearchDetail($M.getValue("menu_seq"));
					}
				}
		);
	}
   
	//갱신
	function fnNew(menuSeq) {
		$("#menu_name").attr("disabled", false);
		$("#menu_name").addClass("essential-bg");
		$M.setValue("menu_seq", menuSeq != undefined ? menuSeq : $M.getValue("menu_seq"));
		$M.setValue("menu_name", menuSeq != undefined ? menuSeq : $M.getValue("menu_seq"));
		$M.setValue("cmd", "C");
		var param = {
			menu_seq : $M.getValue("menu_seq"),
			menu_fnc_no : $M.getValue("menu_seq") == "" ? "" : "F" + $M.lpad($M.getValue("menu_seq"), 5, 0) + "_" + $M.lpad(maxSeq, 3, "0"),
			menu_fnc_name : "",
			mem_no_str : "",
			mem_no_op : "OR",
			mem_no_yn  : "",
			grade_cd_str  : "",
			grade_cd_op  : "OR",
			grade_cd_yn : "",
			job_cd_str  : "",
			job_cd_op  : "OR",
			job_cd_yn : "",
			org_code_str : "",
			org_code_op : "OR",
			org_sub_yn : "",
			org_code_yn : "",
			org_auth_str : "",
			org_auth_op : "OR",
			org_auth_yn : "",
			job_auth_cd_str : "",
			job_auth_cd_op : "OR",
			job_auth_yn : "",
			org_gubun_cd_str : "",
			org_gubun_cd_op : "OR",
			org_gubun_yn : "",
			use_yn : "Y",
			remark : "",
		};

		$M.setValue(param);
	}
   
	//메인그리드
	function createAUIGrid() {
		var gridPros = {
			// rowIdField 설정
			rowIdField : "_$uid",
			// rowNumber 
			showRowNumColumn: true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			enableFilter :true,
		};
		var columnLayout = [
			{
				headerText : "메뉴번호",
				dataField : "menu_seq",
				width : "70",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{ 
				headerText : "메뉴명",
				dataField : "menu_name",
				style : "aui-left aui-link",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "기능명",
				dataField : "menu_fnc_name",
				style : "aui-left",
				editable : false,
				filter : {
					showIcon : true
				}
			},
		];
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, []);
		AUIGrid.bind(auiGrid, "cellClick", function(event){
			if (event.headerText == "메뉴명") {
				goSearchDetail(event.item["menu_seq"]);
			}
		});
   }

	function createAUIGridFnc() {
		var gridPros = {
			// rowIdField 설정
			rowIdField : "_$uid",
			// rowNumber
			showRowNumColumn: true,
			enableFilter : true,
			independentAllCheckBox : true, // 필터됬을때 전체체크 방지
			editable : false,
		};
		var columnLayout = [
			{
				dataField : "menu_seq",
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
		// 실제로 #grid_wrap 에 그리드 생성
		auiGridFnc = AUIGrid.create("#auiGridFnc", columnLayout, gridPros);

		// 그리드 갱신
		AUIGrid.setGridData(auiGridFnc, []);

		AUIGrid.bind(auiGridFnc, "cellClick", function(event){
			if (event.headerText == "기능번호") {
				$M.setValue("cmd", "U");
				goSearchFncDetail(event.item.menu_seq, event.item.menu_fnc_no);
			}
		});
	}

	function compare( a, b ) {
		if ( a.mem_name < b.mem_name ) {
			return -1;
		}
		if ( a.mem_name > b.mem_name ) {
			return 1;
		}
		return 0;
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
								<col width="50px">
								<col width="300px">
								<col width="50px">
								<col width="250px">
								<col width="50px">
								<col width="200px">
								<col width="50px">
								<col width= 200px">
								<col width="50px">
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
									<th>직원명</th>
									<td>
										<input type="text" id="s_mem_name" name="s_mem_name" class="form-control">
									</td>
									<th>직책</th>
									<td>
										<input type="text" style="width : 140px;"
											   id="s_grade_cd"
											   name="s_grade_cd"
											   easyui="combogrid"
											   header="Y"
											   easyuiname="gradeList1"
											   panelwidth="200"
											   maxheight="300"
											   textfield="code_name"
											   multi="Y"
											   idfield="code_value" />
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" id="s_grade_cd_yn" name="s_grade_cd_yn" value="Y">
											<label class="form-check-label" for="s_grade_cd_yn">포함</label>
										</div>
									</td>
									<th>직급</th>
									<td>
										<input type="text" style="width : 140px;"
											   id="s_job_cd"
											   name="s_job_cd"
											   easyui="combogrid"
											   header="Y"
											   easyuiname="jobList1"
											   panelwidth="200"
											   maxheight="300"
											   textfield="code_name"
											   multi="Y"
											   idfield="code_value" />
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" id="s_job_cd_yn" name="s_job_cd_yn" value="Y">
											<label class="form-check-label" for="s_job_cd_yn">포함</label>
										</div>
									</td>
								</tr>
								<tr>
									<th>조직</th>
									<td>
										<input type="text" style="width : 150px;"
											   id="s_org_code"
											   name="s_org_code"
											   easyui="combogrid"
											   header="Y"
											   easyuiname="orgList"
											   panelwidth="200"
											   maxheight="300"
											   textfield="org_name"
											   multi="N"
											   idfield="org_code" />
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" id="s_org_sub_yn" name="s_org_sub_yn" value="Y">
											<label class="form-check-label" for="s_org_sub_yn">하위포함</label>
										</div>
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" id="s_org_code_yn" name="s_org_code_yn" value="Y">
											<label class="form-check-label" for="s_org_code_yn">포함</label>
										</div>
									</td>
									<th>조직구분</th>
									<td>
										<input type="text" style="width : 150px;"
											   id="s_org_gubun_cd"
											   name="s_org_gubun_cd"
											   easyui="combogrid"
											   header="Y"
											   easyuiname="orgGubunList1"
											   panelwidth="200"
											   maxheight="300"
											   textfield="code_name"
											   multi="Y"
											   idfield="code_value" />
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" id="s_org_gubun_yn" name="s_org_gubun_yn" value="Y">
											<label class="form-check-label" for="s_org_gubun_yn">포함</label>
										</div>
									</td>
									<th>부서권한</th>
									<td>
										<input type="text" style="width : 140px;"
											   id="s_org_auth"
											   name="s_org_auth"
											   easyui="combogrid"
											   header="Y"
											   easyuiname="orgAuthList1"
											   panelwidth="240"
											   maxheight="300"
											   textfield="path_org_name"
											   multi="Y"
											   idfield="org_code" />
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" id="s_org_auth_yn" name="s_org_auth_yn" value="Y">
											<label class="form-check-label" for="s_org_auth_yn">포함</label>
										</div>
									</td>
									<th>업무권한</th>
									<td colspan = "3">
										<input type="text" style="width : 140px;"
											   id="s_job_auth_cd"
											   name="s_job_auth_cd"
											   easyui="combogrid"
											   header="Y"
											   easyuiname="jobAuthList1"
											   panelwidth="200"
											   maxheight="300"
											   textfield="code_name"
											   multi="Y"
											   idfield="code_value" />
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" id="s_job_auth_yn" name="s_job_auth_yn" value="Y">
											<label class="form-check-label" for="s_job_auth_yn">포함</label>
										</div>
									</td>
									<td class="">
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
						<div class="col-4">
							<!-- 메뉴정보 -->
							<div class="row">
								<div class="col-12">
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
																<input type="text" class="form-control width230px" id="menu_seq" name="menu_seq" alt="메뉴번호" readonly>
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
															<c:forEach items="${menuList}" var="item">
																<option value="${item.menu_seq}">${item.path_menu_name}</option>
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
														<textarea style="height: 100%;" id="remark" name="remark" alt="비고">${item.self_eval_text }</textarea>
													</td>
												</tr>
												<tr>
													<th class="text-center">직원</th>
													<td>
														<input type="text" style="width : 180px;"
															   id="mem_no_str"
															   name="mem_no_str"
															   easyui="combogrid"
															   header="Y"
															   easyuiname="memList"
															   panelwidth="180"
															   maxheight="300"
															   textfield="mem_name"
															   multi="Y"
															   idfield="mem_no" />
														<div class="form-check form-check-inline checkline">
															<input class="form-check-input" type="checkbox" id="mem_no_yn" name="mem_no_yn" value="Y">
															<label class="form-check-label" for="mem_no_yn">포함</label>
														</div>
														<div style="float: right">
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" id="mem_no_op_and" name="mem_no_op" value="AND" required="required" alt="직원조건연산">
																<label class="form-check-label" for="mem_no_op_and">AND</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" id="mem_no_op_or" name="mem_no_op" value="OR" checked="checked" required="required" alt="직원조건연산">
																<label class="form-check-label" for="mem_no_op_or">OR</label>
															</div>
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-center">직책</th>
													<td>
														<input type="text" style="width : 180px;"
															   id="grade_cd_str"
															   name="grade_cd_str"
															   easyui="combogrid"
															   header="Y"
															   easyuiname="gradeList2"
															   panelwidth="180"
															   maxheight="300"
															   textfield="code_name"
															   multi="Y"
															   idfield="code_value" />
														<div class="form-check form-check-inline checkline">
															<input class="form-check-input" type="checkbox" id="grade_cd_yn" name="grade_cd_yn" value="Y">
															<label class="form-check-label" for="grade_cd_yn">포함</label>
														</div>
														<div style="float: right">
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" id="grade_cd_op_and" name="grade_cd_op" value="AND" required="required" alt="직급조건연산">
																<label class="form-check-label" for="grade_cd_op_and">AND</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" id="grade_cd_op_or" name="grade_cd_op" value="OR" checked="checked" required="required" alt="직급조건연산">
																<label class="form-check-label" for="grade_cd_op_or">OR</label>
															</div>
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-center">직급</th>
													<td>
														<input type="text" style="width : 180px;"
															   id="job_cd_str"
															   name="job_cd_str"
															   easyui="combogrid"
															   header="Y"
															   easyuiname="jobList2"
															   panelwidth="180"
															   maxheight="300"
															   textfield="code_name"
															   multi="Y"
															   idfield="code_value" />
														<div class="form-check form-check-inline checkline">
															<input class="form-check-input" type="checkbox" id="job_cd_yn" name="job_cd_yn" value="Y">
															<label class="form-check-label" for="job_cd_yn">포함</label>
														</div>
														<div style="float: right">
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" id="job_cd_op_and" name="job_cd_op" value="AND" required="required" alt="직책조건연산">
																<label class="form-check-label" for="job_cd_op_and">AND</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" id="job_cd_op_or" name="job_cd_op" value="OR" checked="checked" required="required" alt="직책조건연산">
																<label class="form-check-label" for="job_cd_op_or">OR</label>
															</div>
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-center">조직</th>
													<td>
														<input type="text" style="width : 180px;"
															   id="org_code_str"
															   name="org_code_str"
															   easyui="combogrid"
															   header="Y"
															   easyuiname="orgList"
															   panelwidth="180"
															   maxheight="300"
															   textfield="org_name"
															   multi="Y"
															   idfield="org_code" />
														<div class="form-check form-check-inline checkline">
															<input class="form-check-input" type="checkbox" id="org_sub_yn" name="org_sub_yn" value="Y">
															<label class="form-check-label" for="org_sub_yn">하위포함</label>
														</div>
														<div class="form-check form-check-inline checkline">
															<input class="form-check-input" type="checkbox" id="org_code_yn" name="org_code_yn" value="Y">
															<label class="form-check-label" for="org_code_yn">포함</label>
														</div>
														<div style="float: right">
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" id="org_code_op_and" name="org_code_op" value="AND" required="required" alt="조직조건연산">
																<label class="form-check-label" for="org_code_op_and">AND</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" id="org_code_op_or" name="org_code_op" value="OR" checked="checked" required="required" alt="조직조건연산">
																<label class="form-check-label" for="org_code_op_or">OR</label>
															</div>
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-center">조직구분</th>
													<td>
														<input type="text" style="width : 180px;"
															   id="org_gubun_cd_str"
															   name="org_gubun_cd_str"
															   easyui="combogrid"
															   header="Y"
															   easyuiname="orgGubunList2"
															   panelwidth="180"
															   maxheight="300"
															   textfield="code_name"
															   multi="Y"
															   idfield="code_value" />
														<div class="form-check form-check-inline checkline">
															<input class="form-check-input" type="checkbox" id="org_gubun_yn" name="org_gubun_yn" value="Y">
															<label class="form-check-label" for="org_gubun_yn">포함</label>
														</div>
														<div style="float: right">
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" id="org_gubun_cd_op_and" name="org_gubun_cd_op" value="AND" required="required" alt="조직구분조건연산">
																<label class="form-check-label" for="org_gubun_cd_op_and">AND</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" id="org_gubun_cd_op_or" name="org_gubun_cd_op" value="OR" checked="checked" required="required" alt="조직구분조건연산">
																<label class="form-check-label" for="org_gubun_cd_op_or">OR</label>
															</div>
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-center">부서권한</th>
													<td>
														<input type="text" style="width : 180px;"
															   id="org_auth_str"
															   name="org_auth_str"
															   easyui="combogrid"
															   header="Y"
															   easyuiname="orgAuthList2"
															   panelwidth="240"
															   maxheight="300"
															   textfield="path_org_name"
															   multi="Y"
															   idfield="org_code" />
														<div class="form-check form-check-inline checkline">
															<input class="form-check-input" type="checkbox" id="org_auth_yn" name="org_auth_yn" value="Y">
															<label class="form-check-label" for="org_auth_yn">포함</label>
														</div>
														<div style="float: right">
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" id="org_auth_op_and" name="org_auth_op" value="AND" required="required" alt="부서권한조건연산">
																<label class="form-check-label" for="org_auth_op_and">AND</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" id="org_auth_op_or" name="org_auth_op" value="OR" checked="checked" required="required" alt="부서권한조건연산">
																<label class="form-check-label" for="org_auth_op_or">OR</label>
															</div>
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-center">업무권한</th>
													<td>
														<input type="text" style="width : 180px;"
															   id="job_auth_cd_str"
															   name="job_auth_cd_str"
															   easyui="combogrid"
															   header="Y"
															   easyuiname="jobAuthList2"
															   panelwidth="180"
															   maxheight="300"
															   textfield="code_name"
															   multi="Y"
															   idfield="code_value" />
														<div class="form-check form-check-inline checkline">
															<input class="form-check-input" type="checkbox" id="job_auth_yn" name="job_auth_yn" value="Y">
															<label class="form-check-label" for="job_auth_yn">포함</label>
														</div>
														<div style="float: right">
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" id="job_auth_cd_op_and" name="job_auth_cd_op" value="AND" required="required" alt="업무권한조건연산">
																<label class="form-check-label" for="job_auth_cd_op_and">AND</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" id="job_auth_cd_op_or" name="job_auth_cd_op" value="OR" checked="checked" required="required" alt="업무권한조건연산">
																<label class="form-check-label" for="job_auth_cd_op_or">OR</label>
															</div>
														</div>
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
							</div>
							<!-- /메뉴정보 -->
						</div>
					</div>
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
		</div>
<!-- /contents 전체 영역 -->
</form>
</body>
</html>