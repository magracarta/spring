<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 모바일관리 > 고객앱관리 > 권한관리
-- 작성자 : 정선경
-- 최초 작성일 : 2023-07-11 09:30:29
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
		var cellRowIndex = 0;	// 버튼권한 설정 후 셀클릭 위치지정

		$(document).ready(function() {
			fnInit();
		});

		function fnInit() {
			createLeftAUIGrid();		// 그리드 생성 (고객권한 목록)
			createCenterAUIGrid();		// 그리드 생성 (메뉴목록)
			createRightTopAUIGrid();	// 그리드 생성 (버튼권한 목록)
			createRightBottomAUIGrid();	// 그리드 생성 (추가설정 목록)
		}

		// 그리드생성 (부서권한 목록)
		function createLeftAUIGrid() {
			var gridPros = {
				rowIdField : "c_cust_auth_cd",
				showRowNumColumn : true,
				fillColumnSizeMode : false,
				height : 580
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "고객권한",
				    dataField: "c_cust_auth_name",
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

 			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
 				if(event.dataField == "c_cust_auth_name") {
					var param = {
						"c_cust_auth_cd" : event.item["c_cust_auth_cd"]
					};

					var frm = document.main_form;
	 				$M.setValue(frm, "c_cust_auth_cd", param.c_cust_auth_cd);

					// 버튼권한 목록, 추가설정 목록 그리드 데이터 초기화
					AUIGrid.clearGridData(auiGridRightTop);
					AUIGrid.clearGridData(auiGridRightBottom);

					// 고객권한 메뉴목록 검색
					goSearchMenuList(param);
 				}
			});
		 }

		// 그리드생성 (메뉴목록)
		function createCenterAUIGrid() {
			var gridPros = {
				rowIdField : "c_menu_seq",
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
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var area = value.split(" > ")
						return area[area.length-1];
					},
					filter : {
						showIcon : true
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

			AUIGrid.bind(auiGridCenter, "ready", function(event){
				AUIGrid.showItemsOnDepth(auiGridCenter, 2);
			});

 			AUIGrid.bind(auiGridCenter, "cellClick", function(event) {
 				if(event.dataField == "path_menu_name") {
	 				// treeicon 클릭 or (depth 1이하 and 팝업여부 = N) 이벤트 없음
	 				if(event.treeIcon === true || (event.item.menu_depth < 2 && event.item.pop_yn == "N")) {
	 					return false;
	 				}

	 				cellRowIndex = event.rowIndex;
					var param = {
						"c_menu_seq" 		: event.item["c_menu_seq"],
						"c_cust_auth_cd" 	: event.item["c_cust_auth_cd"],
						"menu_show_yn" 		: event.item["menu_show_yn"]
					};
					var frm = document.main_form;
	 				$M.setValue(frm, "c_menu_seq", param.c_menu_seq);

					// 고객 메뉴 버튼정보, 추가설정 조회
					goSearchMenuDetail(param);
 				}

 				if(event.dataField == "use_yn") {
 					var depth = event.item.menu_depth;
 					var rowItem = AUIGrid.getItemByRowId(auiGridCenter, event.item.c_menu_seq);
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

 					AUIGrid.updateRowsById(auiGridCenter, items2update);
 				}

			});
		}

		// 그리드생성 (버튼권한 목록)
		function createRightTopAUIGrid() {
			var gridPros = {
				rowIdField : "c_btn_seq",
				showRowNumColumn : true,
				fillColumnSizeMode : false,
				showRowAllCheckBox : true,
				editable : true,
				height : 280
			};

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
					width: "60%",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "고객권한일괄적용",
					dataField : "all",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var checked = event.item.btn_chk == "Y" ? "적용" : "적용취소";
							if (confirm("해당 메뉴를 사용중인 모든 고객권한에 [일괄"+checked+"]하시겠습니까?") == true) {
								var param = {
									"c_cust_auth_cd" : $M.getValue("c_cust_auth_cd"),
									"c_btn_seq" : event.item.c_btn_seq,
									"c_menu_seq" : event.item.c_menu_seq,
									"btn_chk" : event.item.btn_chk
								};
								$M.goNextPageAjax(this_page + "/allAuthBtnSave", $M.toGetParam(param), {method : 'post'},
									function(result) {
										if(result.success) {
											// 고객권한 메뉴목록 검색
											goSearchMenuDetail(param);
										}
									}
								);
							}
						}
					},
					labelFunction : function(rowIndex, columnIndex, value,headerText, item) {
						return "적용";
					}
				}
			];
			auiGridRightTop = AUIGrid.create("#auiGridRightTop", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRightTop, []);
		}

		// 그리드생성 (추가설정 목록)
		function createRightBottomAUIGrid () {
			var gridPros = {
				rowIdField : "c_menu_add_cd",
				showRowNumColumn : true,
				fillColumnSizeMode : false,
				showRowAllCheckBox : true,
				editable : true,
				height: 258
			};

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
					dataField : "c_menu_add_name",
					width: "60%",
					style : "aui-left",
					editable : false
				},
				{
					headerText : "고객권한일괄적용",
					dataField : "all",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var checked = event.item.add_chk == "Y" ? "적용" : "적용취소";
							if (confirm("해당 메뉴를 사용중인 모든 고객권한에 [일괄"+checked+"]하시겠습니까?") == true) {
								var param = {
									"c_cust_auth_cd" : $M.getValue("c_cust_auth_cd"),
									"c_menu_seq" : event.item.c_menu_seq,
									"c_menu_add_cd" : event.item.c_menu_add_cd,
									"add_chk" : event.item.add_chk
								};
								$M.goNextPageAjax(this_page + "/allAuthAddSave", $M.toGetParam(param), {method : 'post'},
										function(result) {
											if(result.success) {
												// 고객권한 메뉴목록 검색
												goSearchMenuDetail(param);
											}
										}
								);
							}
						}
					},
					labelFunction : function(rowIndex, columnIndex, value,headerText, item) {
						return "적용";
					}
				}
			];
			auiGridRightBottom = AUIGrid.create("#auiGridRightBottom", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRightBottom, []);
		}

		// 고객권한 목록 검색
		function goSearch() {
			cellRowIndex = 0;
			$M.setValue("copy_c_cust_auth_cd", "");

			// 메뉴목록, 버튼권한목록, 추가설정목록 그리드 데이터 초기화
			AUIGrid.clearGridData(auiGridCenter);
			AUIGrid.clearGridData(auiGridRightTop);
			AUIGrid.clearGridData(auiGridRightBottom);

			var param = {
				"s_cust_auth_name" : $M.getValue("s_cust_auth_name")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGridLeft, result.list);
					}
				}
			);
		}

		// 메뉴목록 상세보기
		function goSearchMenuList(getParam) {
			$M.setValue("copy_yn", "N");
			$M.setValue("copy_c_cust_auth_cd", "");

			var param = {};
			$M.goNextPageAjax(this_page + "/" + getParam.c_cust_auth_cd, $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGridCenter, result.list);
						if(cellRowIndex != 0) {
							AUIGrid.setSelectionByIndex("#auiGridCenter", cellRowIndex, 0);
							if (getParam.c_cust_auth_cd && getParam.c_menu_seq) {
								param.c_cust_auth_cd = getParam.c_cust_auth_cd;
								param.c_menu_seq = getParam.c_menu_seq;
								goSearchMenuDetail(param);
							}
						}
						$("input:checkbox[name='menu_dtl_yn']").prop("checked", false);
					}
				}
			);
		}

		// 버튼권한목록, 추가설정목록 상세보기
		function goSearchMenuDetail(getParam) {
			// 권한복사여부 초기화
			$M.setValue("copy_yn", "N");
			$M.setValue("copy_c_cust_auth_cd", "");

			// 데이터 그리드 초기회
			AUIGrid.clearGridData(auiGridRightTop);
			AUIGrid.clearGridData(auiGridRightBottom);

			var param = {
					"c_cust_auth_cd" : getParam.c_cust_auth_cd,
					"c_menu_seq" : getParam.c_menu_seq
			};
			$M.goNextPageAjax(this_page + "/" + getParam.c_cust_auth_cd + "/" + getParam.c_menu_seq, $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						// 데이터 그리드 세팅
						AUIGrid.setGridData(auiGridRightTop, result.auth_btn_list);
						AUIGrid.setGridData(auiGridRightBottom, result.auth_add_list);
					}
				}
			);
		}

		// 필드값으로 아이템들 얻기
		function getItemsByField(targetGrid, fieldName, rtnFieldName) {
			// 그리드 데이터에서 btn_chk 필드의 값이 Y 인 행 아이템 모두 반환
			var activeItems = AUIGrid.getItemsByValue(targetGrid, fieldName, "Y");
			var ids = [];
			for(var i=0, len=activeItems.length; i<len; i++) {
				ids.push(activeItems[i][rtnFieldName]); // chk여부가 Y인 값만 저장
			}
			return ids;
		}

		// 메뉴저장
		function goSave() {
			var frm = document.main_form;
			frm = $M.toValueForm(frm);

			var changeGridData = AUIGrid.getEditedRowItems(auiGridCenter);
			if (changeGridData.length == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			var c_menu_seq = [];
			var use_yn = [];

			for (var i = 0; i < changeGridData.length; i++) {
				c_menu_seq.push(changeGridData[i].c_menu_seq);
				use_yn.push(changeGridData[i].use_yn);
			}

			var option = {
				isEmpty : true
			};

			$M.setValue(frm, "upt_menu_seq_str", $M.getArrStr(c_menu_seq, option));
			$M.setValue(frm, "use_yn_str", $M.getArrStr(use_yn, option));

			$M.goNextPageAjaxSave(this_page + "/menuSave", frm, {method : 'POST'},
				function(result) {
					if(result.success) {
						var param = {
							"c_cust_auth_cd" : $M.getValue("c_cust_auth_cd")
						};

						AUIGrid.clearGridData(auiGridRightTop);
						AUIGrid.clearGridData(auiGridRightBottom)

						// 고객권한 메뉴목록 검색
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
			var field = ["s_c_cust_auth_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}

		// 메뉴 상세보기
		function fnMenuDetailInfo() {
			if($M.getValue("menu_dtl_yn") == "Y") {
				AUIGrid.expandAll(auiGridCenter);
			} else {
				AUIGrid.showItemsOnDepth(auiGridCenter, 2);
			}
		}

		// 고객권한관리 팝업 오픈
		function goAuthMngPop() {
			var param = {
				group_code : "C_CUST_AUTH",
				all_yn: "Y",
			}
			openGroupCodeDetailPanel($M.toGetParam(param));
		}

		// 권한복사
		function fnCopyAuth() {
			var custAuthCd = $M.getValue("c_cust_auth_cd");
			var copyCustAuthCd = $M.getValue("copy_c_cust_auth_cd");
			if (custAuthCd == "") {
				alert("고객권한을 선택해주세요.");
				return false;
			}
			if (copyCustAuthCd == "") {
				alert("복사할 권한을 선택해주세요.");
				return false;
			}

			var msg = "권한을 복사하면 현재 메뉴목록이 변경됩니다.\n복사하시겠습니까?";
			if (confirm(msg)) {
				$M.setValue("copy_yn", "Y");
				var param = {
					"c_cust_auth_cd" : copyCustAuthCd
				};
				$M.goNextPageAjax(this_page + "/copyAuth", $M.toGetParam(param), {method : 'GET'},
						function(result) {
							if(result.success) {
								var list = result.list;
								var updateArr = [];
								for (var i=0; i<list.length ; ++i) {
									var item = {};
									item.c_menu_seq = list[i].c_menu_seq;
									item.use_yn = list[i].use_yn;
									item.btn_cnt = list[i].btn_cnt+"";
									item.add_cnt = list[i].add_cnt+"";
									updateArr.push(item);
								}
								AUIGrid.updateRowsById(auiGridCenter, updateArr);
								AUIGrid.clearGridData(auiGridRightTop);
								AUIGrid.clearGridData(auiGridRightBottom);
							}
						}
				);
			}
		}

		// 버튼정보, 추가설정 저장
		function goSaveDetail() {
			var changeGridData = AUIGrid.getEditedRowItems(auiGridCenter);
			if (changeGridData.length != 0) {
				alert("변경한 메뉴목록을 먼저 저장 후 진행해주세요.");
				return false;
			}
			if (fnChangeGridDataCnt(auiGridRightTop) == 0 && fnChangeGridDataCnt(auiGridRightBottom) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			var cBtnCheckData = getItemsByField(auiGridRightTop, "btn_chk", "c_btn_seq");
			var remove_all_yn = "N"; // N이면 값 넣음 Y면 삭제
			// 버튼권한 목록 체크된게 없으면 remove_all_yn = Y, DELETE 실행
			if(cBtnCheckData.length == 0) {
				remove_all_yn = "Y";
			}

			var addChangeData = AUIGrid.getEditedRowItems(auiGridRightBottom);
			var cMenuAddCds = [];
			for(var i=0; i < addChangeData.length; i++) {
				cMenuAddCds.push(addChangeData[i].c_menu_add_cd);
			}

			var param = {
				"c_cust_auth_cd" : $M.getValue("c_cust_auth_cd"),
				"c_menu_seq" : $M.getValue("c_menu_seq"),
				"c_btn_seq_str" : $M.getArrStr(cBtnCheckData),
				"remove_all_yn" : remove_all_yn,
				"c_menu_add_cd_str" : $M.getArrStr(cMenuAddCds),
				"copy_yn" : $M.getValue("copy_yn")
			};
			$M.goNextPageAjaxSave(this_page+"/dtlSave", $M.toGetParam(param), {method : "POST"},
				function(result) {
					if(result.success) {
						// 저장 시 메뉴목록 갱신
						AUIGrid.resetUpdatedItems(auiGridCenter);
						goSearchMenuList(param);

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
	<input type="hidden" id="c_cust_auth_cd" name="c_cust_auth_cd">
	<input type="hidden" id="c_menu_seq" name="c_menu_seq">
	<input type="hidden" id="upt_menu_seq_str" name="upt_menu_seq_str">
	<input type="hidden" id="use_yn_str" name="use_yn_str">
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
								<th>고객권한</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" id="s_c_cust_auth_name" name="s_c_cust_auth_name" class="form-control">
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
							<h4>고객권한 목록</h4>
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
										<div class="select-section ml15 mr5 width200px">
											<select class="form-control" id="copy_c_cust_auth_cd" name="copy_c_cust_auth_cd" style="width: 100%;">
												<option value="">- 선택 -</option>
												<c:forEach var="list" items="${codeMap['C_CUST_AUTH']}">
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
							<div class="left mt5">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
							</div>
							<div class="right mt5" style="text-align: right;">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
					<div class="col-4">
						<div class="title-wrap mt10">
							<h4>버튼권한 목록</h4>
						</div>
						<div id="auiGridRightTop" style="margin-top: 5px;"></div>
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