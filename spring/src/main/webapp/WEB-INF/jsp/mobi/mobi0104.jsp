<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 업무권한관리 > null > null
-- 작성자 : 정선경
-- 최초 작성일 : 2023-01-31 11:03:28
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGridLeft;
		var auiGridCenter;
		var auiGridRightTop;
		var auiGridRightBottom;

		$(document).ready(function() {
			createLeftAUIGrid();		// 그리드 생성 (업무권한 목록)
			createCenterAUIGrid();		// 그리드 생성 (메뉴목록)
			createRightTopAUIGrid();	// 그리드 생성 (버튼권한 목록)
			createRightBottomAUIGrid();	// 그리드 생성 (추가설정 목록)
		});
		
		var cellRowIndex = 0;	// 버튼권한 설정 후 셀클릭 위치지정
		
		// 그리드생성
		function createLeftAUIGrid() {
			var gridPros = {
				rowIdField : "code",
				showRowNumColumn : true,
				fillColumnSizeMode : false,
				height : 580
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "업무권한",
				    dataField: "code_name",
					style : "aui-left aui-link"
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					width: "20%",
					style : "aui-center"
				}
			];
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridLeft, []);
			// 클릭한 셀 데이터 받음
 			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
 				if(event.dataField == "code_name") {
					var param = {
						"job_auth_cd" : event.item["code"]
					};
	 				console.log("1. job_auth_cd = " + param.job_auth_cd);
					// job_auth_cd hidden에 저장
					var frm = document.main_form;
	 				$M.setValue(frm, "job_auth_cd", param.job_auth_cd);
	 				// 셀렉트박스 초기화
	 				initSelectBox();
					// 버튼권한 목록 그리드 데이터 초기화
					AUIGrid.clearGridData(auiGridRightTop);
					AUIGrid.clearGridData(auiGridRightBottom);
					// 메뉴목록 검색
					goSearchMenuList(param);
 				}
			});
		 }
		
		// 그리드생성
		function createCenterAUIGrid() {
			var gridPros = {
				rowIdField : "m_menu_seq",
				showRowNumColumn : false,
				treeColumnIndex : 0,
				height : 580,
				editable : false,
				fillColumnSizeMode : false,
				enableFilter : true,
				showStateColumn : true
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "메뉴",
					dataField : "path_menu_name",
					width: "40%",
					style : "aui-left aui-link",
					filter : {
						showIcon : true
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var area = value.split(" > ")
						return area[area.length-1];
					}
				},
				{ 
					headerText : "사용여부", 
					dataField : "use_yn",
					width : "11%",
					style : "aui-center",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "버튼 수",
					dataField : "btn_cnt",
					width: "12%",
					style : "aui-center"
				},
				{
					headerText : "추가설정 수",
					dataField : "add_cnt",
					width: "12%",
					style : "aui-center"
				},
				{
					headerText : "추가설정 가능 항목",
					dataField : "add_names",
					width: "25%",
					style : "aui-left",
					filter : {
						showIcon : true
					}
				},
				{
					dataField : "depth_1",
					visible : false
				},
				{
					dataField : "depth_2",
					visible : false
				},
				{
					dataField : "depth_3",
					visible : false
				},
				{
					dataField : "depth_4",
					visible : false
				}
			];
			auiGridCenter = AUIGrid.create("#auiGridCenter", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridCenter, []);
			// 그리드 ready 이벤트 바인딩
			AUIGrid.bind(auiGridCenter, "ready", function(event){
				AUIGrid.showItemsOnDepth(auiGridCenter, 3);
			});
 			// 클릭한 셀 데이터 받음
 			AUIGrid.bind(auiGridCenter, "cellClick", function(event) {
 				if(event.dataField == "path_menu_name") {
	 				// treeicon 클릭 or (depth 1이하 and 팝업여부 = N) 이벤트 없음
	 				if(event.treeIcon === true || (event.item.menu_depth < 2 && event.item.pop_yn == "N")) {
	 					return;
	 				};
	 				cellRowIndex = event.rowIndex;	// 클릭한 로우index 저장
					var param = {
						"m_menu_seq" 		: event.item["m_menu_seq"],
						"job_auth_cd" 		: event.item["job_auth_cd"],
						"menu_show_yn" 		: event.item["menu_show_yn"],
						"search_limit_yn" 	: event.item["search_limit_yn"],
						"search_auth_cd" 	: event.item["search_auth_cd"],
					};
					console.log("2. 조회제한 권한 값 : " + param.search_auth_cd);
					// hidden 값 저장
					var frm = document.main_form;
	 				$M.setValue(frm, "m_menu_seq", param.m_menu_seq);
	 				$M.setValue(frm, "search_limit_yn", param.search_limit_yn);
	 				// 조회제한 권한값이 없을때 기본값 ALL 고정
	 				if(param.search_auth_cd.length == 0) {
	 					$M.setValue("search_auth_cd", "ALL");
	 				} else {
		 				$M.setValue("search_auth_cd", param.search_auth_cd);
	 				};
	 				goSearchMenuDetail(param);
 				}
 				if(event.dataField == "use_yn") {
 					var depth = event.item.menu_depth;
 					var rowItem = AUIGrid.getItemByRowId(auiGridCenter, event.item.m_menu_seq);
 					var depthNGroup;
 					var items;
 					switch(depth) {
 						case "1" : depthNGroup = rowItem.depth_1;
 							items = AUIGrid.getItemsByValue(auiGridCenter, "depth_1", depthNGroup);
 							break;
 						case "2" : depthNGroup = rowItem.depth_2;
 							items = AUIGrid.getItemsByValue(auiGridCenter, "depth_2", depthNGroup);
 							break;
 						case "3" : depthNGroup = rowItem.depth_3;
 							items = AUIGrid.getItemsByValue(auiGridCenter, "depth_3", depthNGroup);
 							break;
 						case "4" : depthNGroup = rowItem.depth_4;
 							items = AUIGrid.getItemsByValue(auiGridCenter, "depth_4", depthNGroup);
 							break;
 					}
 					var rowIdField = AUIGrid.getProp(auiGridCenter, "rowIdField");
 					var items2update = [];
 					var item, obj;
 					if(event.value == "Y") {
 						for(var i=0, len=items.length; i<len; i++) {
 						      item = items[i];
 						      obj = {};
 						      obj[rowIdField] = item[rowIdField];
 						      obj["use_yn"] = "Y";
 						      items2update.push(obj);
 						}
 					} else {
 						for(var i=0, len=items.length; i<len; i++) {
 						      item = items[i];
 						      obj = {};
 						      obj[rowIdField] = item[rowIdField];
 						      obj["use_yn"] = "N";
 						      items2update.push(obj);
 						}
 					}
 					// 일괄 업데이트
 					AUIGrid.updateRowsById(auiGridCenter, items2update);
 				}
			});
		}

		// 그리드생성
		function createRightTopAUIGrid() {
			var gridPros = {
				rowIdField : "m_btn_seq",
				showRowNumColumn : true,
				fillColumnSizeMode : false,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				editable : true,
				height : 280
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "",
					dataField : "btn_chk", 
					width : "10%", 
					style : "aui-center",
					headerRenderer : { // 헤더 렌더러
						type : "CheckBoxHeaderRenderer",
						dependentMode : true
					},
					renderer : {
						type : "CheckBoxEditRenderer",
						checkValue : "Y", // true, false 인 경우가 기본
						unCheckValue : "N",
						editable : true
					}
				},
				{
					headerText : "버튼",
					dataField : "btn_name",
					width: "90%",
					style : "aui-center",
					editable : false
				}
			];
			auiGridRightTop = AUIGrid.create("#auiGridRightTop", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRightTop, []);
		}

		// 그리드생성 (추가설정 목록)
		function createRightBottomAUIGrid () {
			var gridPros = {
				rowIdField : "m_menu_add_cd",
				showRowNumColumn : true,
				fillColumnSizeMode : false,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				editable : true,
				height: 258
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "",
					dataField : "add_chk",
					width : "10%",
					style : "aui-center",
					headerRenderer : { // 헤더 렌더러
						type : "CheckBoxHeaderRenderer",
						dependentMode : true
					},
					renderer : {
						type : "CheckBoxEditRenderer",
						checkValue : "Y", // true, false 인 경우가 기본
						unCheckValue : "N",
						editable : true
					}
				},
				{
					headerText : "항목",
					dataField : "m_menu_add_name",
					style : "aui-left",
					editable : false
				}
			];
			auiGridRightBottom = AUIGrid.create("#auiGridRightBottom", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRightBottom, []);
		}
		
		// 업무권한 목록 조회
		function goSearch() {
			cellRowIndex = 0;
			$M.setValue("copy_job_auth_cd", "");
			// 메뉴목록, 버튼권한목록 그리드 데이터 초기화
			AUIGrid.clearGridData(auiGridCenter);
			AUIGrid.clearGridData(auiGridRightTop);
			AUIGrid.clearGridData(auiGridRightBottom);

			var param = {
				"s_code_name" : $M.getValue("s_code_name")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGridLeft, result.list);	
					};
				}
			);
		}

		// 메뉴목록 상세보기
		function goSearchMenuList(getParam) {
			// 권한복사여부 초기화
			$M.setValue("copy_yn", "N");
			$M.setValue("copy_job_auth_cd", "");
			$M.goNextPageAjax(this_page + "/" + getParam.job_auth_cd, "", {method : "get"},
				function(result) {
					if(result.success) {
						// 데이터 그리드 세팅
						AUIGrid.setGridData(auiGridCenter, result.list);
						if(cellRowIndex != 0) {
							AUIGrid.setSelectionByIndex("#auiGridCenter", cellRowIndex, 0);
						};
						$("input:checkbox[name='menu_dtl_yn']").prop("checked", false);
					};
				}	
			);
		}
		
		// 버튼권한목록 상세보기
		function goSearchMenuDetail(getParam) {
			// 권한복사여부 초기화
			$M.setValue("copy_yn", "N");
			$M.setValue("copy_job_auth_cd", "");

			// 데이터 그리드 초기회
			AUIGrid.clearGridData(auiGridRightTop);
			AUIGrid.clearGridData(auiGridRightBottom);

			$M.goNextPageAjax(this_page + "/" + getParam.job_auth_cd + "/" + getParam.m_menu_seq, "", {method : "get"},
				function(result) {
					if(result.success) {
						// 데이터 그리드 세팅
						AUIGrid.setGridData(auiGridRightTop, result.jobBtnList);
						AUIGrid.setGridData(auiGridRightBottom, result.jobAddList);

						var checkedList = [];	
						$.each(result.jobBtnList, function(i, item) {
							checkedList.push(item.btn_chk);
						});
						// 조회제한 권한 설정 search_limit_yn 노출여부
						if(getParam.search_limit_yn == "Y") {
							$('#search_auth_cd').attr('disabled', false);
						} else if (getParam.search_limit_yn == "N") {
							$('#search_auth_cd').attr('disabled', true);
						};
					};
				}	
			);
		}
		
		// 특정 칼럼 값 체크하기
		function setCheckedRowsByValue(checkedList) {
			AUIGrid.setCheckedRowsByValue(auiGridRightTop, "btn_chk", checkedList);
		};
		
		// 필드값으로 아이템들 얻기
		function getItemsByField() {
			// 그리드 데이터에서 isActive 필드의 값이 Active 인 행 아이템 모두 반환
			var activeItems = AUIGrid.getItemsByValue(auiGridRightTop, "btn_chk", "Y");
			// alert(activeItems);
			var ids = [];
			for(var i=0, len=activeItems.length; i<len; i++) {
				ids.push(activeItems[i].m_btn_seq); // btn_chk가 Y인 값만 저장 
			};
			return ids;
		}

		function goSave() {
			var frm = document.main_form;
			frm = $M.toValueForm(frm);

			var changeGridData = AUIGrid.getEditedRowItems(auiGridCenter); // 변경내역
			if (changeGridData.length == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			var m_menu_seq = [];
			var use_yn = [];

			for (var i = 0; i < changeGridData.length; i++) {
				m_menu_seq.push(changeGridData[i].m_menu_seq);
				use_yn.push(changeGridData[i].use_yn);
			}

			var option = {
				isEmpty : true
			};

			$M.setValue(frm, "upt_menu_seq_str", $M.getArrStr(m_menu_seq, option));
			$M.setValue(frm, "use_yn_str", $M.getArrStr(use_yn, option));

			$M.goNextPageAjaxSave(this_page + "/menuSave", frm, {method : 'POST'},
					function(result) {
						if(result.success) {
							var param = {
								"job_auth_cd" : $M.getValue("job_auth_cd")
							};
							// 버튼권한 목록 그리드 데이터 초기화
							AUIGrid.clearGridData(auiGridRightTop);
							// 해당 업무 메뉴목록 검색
							goSearchMenuList(param);
						}
					}
			);
		}

		//팝업 닫기
		function fnClose() {
			window.close(); 
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_code_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}

		//상위메뉴 onclick
		function initSelectBox() {
			var frm = document.main_form;
			$("input:checkbox[id='search_auth_cd']").is(":checked");
			$("#search_auth_cd").attr("disabled",true);
			$("#search_auth_cd").attr("class","readonly");
			// 조회제한 권한 초기값 ALL 고정
			$M.setValue(frm, "search_auth_cd", "ALL");
		}
		
		function fnMenuDetailInfo() {
			if($M.getValue("menu_dtl_yn") == "Y") {
				AUIGrid.expandAll(auiGridCenter);
			} else {
				AUIGrid.showItemsOnDepth(auiGridCenter, 3);
			}
		}

		// 업무권한관리 팝업 오픈
		function goAuthMngPop() {
			var param = {
				group_code : "JOB_AUTH",
				all_yn: "Y",
			}
			openGroupCodeDetailPanel($M.toGetParam(param));
		}

		// 권한복사
		function fnCopyAuth() {
			var jobAuthCd = $M.getValue("job_auth_cd");
			var copyJobAuthCd = $M.getValue("copy_job_auth_cd");
			if (jobAuthCd == "") {
				alert("업무권한을 선택해주세요.");
				return false;
			}
			if (copyJobAuthCd == "") {
				alert("복사할 권한을 선택해주세요.");
				return false;
			}

			var msg = "권한을 복사하면 현재 메뉴목록이 변경됩니다.\n복사하시겠습니까?";
			if (confirm(msg)) {
				$M.setValue("copy_yn", "Y");
				var param = {
					"job_auth_cd" : copyJobAuthCd
				};
				$M.goNextPageAjax(this_page + "/copyAuth", $M.toGetParam(param), {method : "get"},
						function(result) {
							if(result.success) {
								if(result.success) {
									var list = result.list;
									var updateArr = [];
									for (var i=0; i<list.length ; ++i) {
										var item = {};
										item.m_menu_seq = list[i].m_menu_seq;
										item.use_yn = list[i].use_yn;
										item.btn_cnt = list[i].btn_cnt;
										item.add_cnt = list[i].add_cnt+"";
										item.search_limit_yn = list[i].search_limit_yn;
										item.search_auth_cd = list[i].search_auth_cd;
										updateArr.push(item);
									}
									AUIGrid.updateRowsById(auiGridCenter, updateArr);
									// 초기화
									AUIGrid.clearGridData(auiGridRightTop);
									AUIGrid.clearGridData(auiGridRightBottom);
									$M.setValue("search_auth_cd", "ALL");
								}
							};
						}
				);
			}
		}

		// 버튼정보, 조회제한설정, 추가설정 저장
		function goSaveDetail() {
			var changeGridData = AUIGrid.getEditedRowItems(auiGridCenter); // 변경내역
			if (changeGridData.length != 0) {
				alert("변경한 메뉴목록을 먼저 저장 후 진행해주세요.");
				return false;
			}
			if (fnChangeGridDataCnt(auiGridRightTop) == 0 && fnChangeGridDataCnt(auiGridRightBottom) == 0 && $M.getValue("search_limit_yn") == "N"){
				alert("변경된 데이터가 없습니다.");
				return false;
			};

			var checkData = getItemsByField();
			var remove_all_yn = "N"; // N이면 값 넣음 Y면 삭제
			// 버튼권한 목록 체크된게 없으면 remove_all_yn = Y, DELETE 실행
			if(checkData.length == 0) {
				remove_all_yn = "Y";
			};

			var addChangeData = AUIGrid.getEditedRowItems(auiGridRightBottom); // 추가설정 변경내역
			var menuAddCds = [];
			for(var i=0; i < addChangeData.length; i++) {
				menuAddCds.push(addChangeData[i].m_menu_add_cd);
			}

			var param = {
				"job_auth_cd" : $M.getValue("job_auth_cd"),
				"m_menu_seq" : $M.getValue("m_menu_seq"),
				"m_btn_seq_str" : $M.getArrStr(checkData),
				"remove_all_yn" : remove_all_yn,
				"search_auth_cd" : $M.getValue("search_auth_cd"),
				"search_limit_yn" : $M.getValue("search_limit_yn"),
				"m_menu_add_cd_str" : $M.getArrStr(menuAddCds),
				"copy_yn" : $M.getValue("copy_yn")
			};

			$M.goNextPageAjaxSave(this_page + "/dtlSave", $M.toGetParam(param), {method : "POST"},
					function(result) {
						if(result.success) {
							// 저장 여러번 실행 시 에러발생 확인요망
							var rowIndex = AUIGrid.getSelectedIndex(auiGridCenter)[0];
							AUIGrid.updateRow(auiGridCenter, {"search_auth_cd" : $M.getValue("search_auth_cd")}, rowIndex);
							AUIGrid.resetUpdatedItems(auiGridCenter);
							goSearchMenuDetail(param);
							// 권한복사여부 초기화
							$M.setValue("copy_yn", "N");
							$M.setValue("copy_job_auth_cd", "");
						};
					}
			);
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<input type="hidden" id="job_auth_cd" name="job_auth_cd">
	<input type="hidden" id="m_menu_seq" name="m_menu_seq">
	<input type="hidden" id="search_limit_yn" name="search_limit_yn">
	<input type="hidden" id="copy_yn" name="copy_yn" value="N">
	<!-- contents 전체 영역 -->
	<div class="content-wrap" style="height: 850px;">
		<div class="content-box">
			<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /메인 타이틀 -->
			<div class="contents">
				<!-- 검색조건 -->
				<div class="search-wrap">
					<table class="table">
						<colgroup>
							<col width="70px">
							<col width="200px">
							<col width="*">
						</colgroup>
						<tbody>
							<tr>
								<th>업무권한</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" id="s_code_name" name="s_code_name" class="form-control">
									</div>
								</td>
								<td class=""><button type="button" class="btn btn-important" onclick="javascript:goSearch();" style="width: 50px;">조회</button></td>
							</tr>
						</tbody>
					</table>
				</div>
				<!-- /검색조건 -->
				<div class="row">
					<div class="col-3">
						<div class="title-wrap mt10">
							<h4>업무권한 목록</h4>
							<div class="btn-group">
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
								</div>
							</div>
						</div>
						<div id="auiGridLeft" style="margin-top: 5px;"></div>
					</div>
					<div class="col-5">
						<div class="title-wrap mt10">
							<h4>메뉴목록</h4>
							<div class="btn-group">
								<div class="right">
									<div class="form-row inline-pd" style="float: right;">
										<input type="checkbox" id="menu_dtl_yn" name="menu_dtl_yn" value="Y" onclick="javascript:fnMenuDetailInfo();">
										<label for="menu_dtl_yn">상세보기</label>
										<div class="select-section ml15 mr5 width150px">
											<select class="form-control" name="copy_job_auth_cd" id="copy_job_auth_cd">
												<option value="">- 선택 -</option>
												<c:forEach var="list" items="${codeMap['JOB_AUTH']}">
													<option value="${list.code_value}">${list.code_name}</option>
												</c:forEach>
											</select>
										</div>
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
									</div>
								</div>
							</div>
						</div>
						<div id="auiGridCenter" style="margin-top: 5px;"></div>
						<div class="btn-group">
							<div class="right mt5" >
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
					<div class="col-4">
						<div class="title-wrap mt10">
							<h4>버튼권한 목록</h4>
						</div>
						<div id="auiGridRightTop" style="margin-top: 5px;"></div>
						<!-- 조회제한 권한 설정 영역 -->
<%--						<div class="grant-wrap">--%>
<%--							<div class="title-wrap mt10">--%>
<%--								<h4>조회제한 권한 설정</h4>--%>
<%--							</div>--%>
<%--							<div>--%>
<%--								<table class="table-border mt5">--%>
<%--									<colgroup>--%>
<%--										<col width="100px">--%>
<%--									</colgroup>--%>
<%--									<tbody>--%>
<%--										<tr>--%>
<%--											<th class="text-right essential-item">조회제한 권한</th>--%>
<%--											<td>--%>
<%--												<select class="form-control essential-bg" id="search_auth_cd" name="search_auth_cd" style="width: 100%;" disabled="disabled">--%>
<%--													<c:forEach var="list" items="${codeMap['SEARCH_AUTH']}">--%>
<%--													<option value="${list.code_value}">${list.code_name}</option>--%>
<%--													</c:forEach>--%>
<%--												</select>--%>
<%--											</td>--%>
<%--										</tr>--%>
<%--									</tbody>--%>
<%--								</table>--%>
<%--							</div>--%>
<%--						</div>--%>
						<!-- /조회제한 권한 설정 영역 -->
						<!-- 추가설정 -->
						<div class="title-wrap mt10">
							<h4>추가설정</h4>
						</div>
						<!-- 그리드 생성 -->
						<div id="auiGridRightBottom" style="margin-top: 5px;"></div>
						<!-- /추가설정 -->
						<!-- 버튼영역 -->
						<div class="btn-group mt5">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
							</div>
						</div>
						<!-- /버튼영역 -->
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