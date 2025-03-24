<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 직책관리 > null > null
-- 작성자 : 정선경
-- 최초 작성일 : 2022-12-06 17:53:47
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGridLeft;
		var auiGridRight;
		var gradeCdJson = JSON.parse('${codeMapJsonObj['GRADE']}');
		var orgAuthJson = ${orgAuthList};

		$(document).ready(function() {
			createLeftAUIGrid();	// 그리드 생성 (조직목록)
			createRightAUIGrid();	// 그리드 생성 (처리내역)
		});

		// 그리드생성 (조직목록)
		function createLeftAUIGrid() {
			var gridPros = {
				rowIdField : "org_code",
				enableSorting : false,
				displayTreeOpen : false,
				rowCheckDependingTree : true,
				showRowNumColumn : false,
				treeColumnIndex : 1,
				height: 580
			};
			var columnLayout = [
				{
					headerText : "조직",
					dataField : "org_code",
					width : "15%",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "조직명",
					dataField : "org_name",
					width : "45%",
					style : "aui-left aui-link",
					editable : false
				},
				{
					headerText : "소속직책",
					dataField : "grade_name_str",
					style : "aui-left",
					editable : false
				}
			];

			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridLeft, []);
			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
				if (event.dataField == "org_name") {
					$M.setValue("org_code", event.item["org_code"]);
					goSearchDetail();
				}
			});

			$("#auiGridLeft").resize();
		}

		// 그리드생성 (처리내역)
		function createRightAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : false,
				enableSorting : false,
				editable : true,
				height: 580,
				showStateColumn:true
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "직책",
					dataField : "grade_cd_str",
					width : "40%",
					style : "aui-center aui-editable",
					editable : true,
					required : true,
					editRenderer: {
						type: "DropDownListRenderer",
						multipleMode: true,
						showCheckAll: true,
						list: gradeCdJson,
						keyField : "code_value",
						valueField  : "code_name",
						showEditorBtn: true,
						showEditorBtnOver: true,
						delimiter: ", " // 다중 선택시 구분자
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						if (value != null && value != "") {
							var valueArr = value.split(", ");
							var tempValueArr = [];
							for (var i = 0; i < gradeCdJson.length; i++) {
								if (valueArr.indexOf(gradeCdJson[i]["code_value"]) >= 0) {
									tempValueArr.push(gradeCdJson[i]["code_name"]);
								}
							}
							return tempValueArr.sort().join(", ");
						}
						return "";
					}
				},
				{
					headerText : "부서권한",
					dataField : "auth_org_code",
					required : true,
					showEditorBtn : true,
					showEditorBtnOver : true,
					editable : true,
					style : "aui-left aui-editable",
					editRenderer : {
						type : "DropDownListRenderer",
						list : orgAuthJson,
						listAlign : "left",
						keyField : "org_code",
						valueField  : "path_org_name"
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						var retStr = value;
						for(var i = 0; i < orgAuthJson.length; i++) {
							if (value == orgAuthJson[i].org_code) {
								retStr = orgAuthJson[i].path_org_name;
							} else if (value == null || value == "") {
								retStr = "- 선택 -";
							}
						}
						return retStr;
					}
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "15%",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridRight, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGridRight, {cmd : "D"}, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGridRight, "selectedIndex");
							};
							AUIGrid.update(auiGridRight);
						},
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				},
				{
					dataField : "cmd",
					visible : false
				},
				{
					dataField : "origin_auth_org_code",
					visible : false
				}
			];
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRight, []);
			AUIGrid.bind(auiGridRight, "cellEditEnd", function(event) {
				if (event.dataField == "auth_org_code" && event.item.cmd == "C") {
					AUIGrid.setCellValue(auiGridRight ,event.rowIndex, "origin_auth_org_code", event.item.auth_org_code);
				}
			});
		}

		// 조직목록 조회
		function goSearch() {
			$M.setValue("org_code", "");
			$M.setValue("sub_org_apply_yn", "");
			AUIGrid.clearGridData(auiGridLeft);
			AUIGrid.clearGridData(auiGridRight);
			var param = {
				"s_org_code" : $M.getValue("s_org_code")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : "GET"},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGridLeft, result.list);
							AUIGrid.expandAll(auiGridLeft);
						};
					}
			);
		}

		// 처리내역 조회
		function goSearchDetail() {
			var param = {
				org_code: $M.getValue("org_code")
			}
			$M.goNextPageAjax(this_page + "/detail", $M.toGetParam(param), {method : "GET"},
					function(result) {
						if(result.success) {
							var list = result.list;
							AUIGrid.setGridData(auiGridRight, list);
							for (var i=0; i<list.length; i++) {
								list[i].origin_auth_org_code = list[i].auth_org_code;
							}
							AUIGrid.setGridData(auiGridRight, list);
						};
					}
			);
		}

		// 처리내역 저장
		function goSave() {
			var subOrgApplyYn = $M.getValue("sub_org_apply_yn");
			if ((subOrgApplyYn != "Y" && fnGetUpdatedItemsCnt(auiGridRight) == 0)) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}
			if(!AUIGrid.validation(auiGridRight)) {
				return false;
			}

			var msg = "저장하시겠습니까?";
			if ($M.getValue("sub_org_apply_yn") == "Y") {
				msg = "하위조직까지 일괄적용됩니다.\n" + msg;
			}

			if (confirm(msg)) {
				var frm = $M.toValueForm(document.main_form);
				var gridFrm = fnChangeGridDataToForm(auiGridRight);
				$M.copyForm(gridFrm, frm);

				$M.goNextPageAjax(this_page + "/save", gridFrm, {method : "POST"},
						function(result) {
							if(result.success) {
								goSearchDetail();
								$M.setValue("sub_org_apply_yn", "");
							};
						}
				);
			}
		}

		// 직책코드관리 팝업
		function goJobCdMngPop() {
			var param = {
				group_code : "GRADE",
				all_yn: "Y",
				parent_js_name: "fnCallBack",
				show_extra_cols : "v1,v2,v3,v4,v5,v6,v8",
				requireds : "v3",
			}
			openGroupCodeDetailPanel($M.toGetParam(param));
		}

		// 행추가
		function fnAdd() {
			if (!$M.getValue("org_code")) {
				alert("조직을 먼저 선택해주세요.");
				return false;
			}
			var item = new Object();
			item.grade_cd_str = "";
			item.auth_org_code = "";
			item.cmd = "C";
			AUIGrid.addRow(auiGridRight, item, "last");
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<input type="hidden" id="org_code" name="org_code">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
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
								<col width="70px">
								<col width="200px">
								<col width="*">
							</colgroup>
							<tbody>
							<tr>
								<th>조직</th>
								<td>
									<select id="s_org_code" name="s_org_code" class="form-control">
										<option value="">- 전체 -</option>
										<c:forEach items="${orgList}" var="item">
											<option value="${item.org_code}">${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<td class=""><button type="button" class="btn btn-important" onclick="javascript:goSearch();" style="width: 50px;">조회</button></td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<div class="row">
						<div class="col-4">
							<div class="title-wrap mt10">
								<h4>조직목록</h4>
								<div class="btn-group">
									<div class="right">
										<button type="button" class="btn btn-default" onclick=AUIGrid.expandAll(auiGridLeft);><i class="material-iconsadd text-default"></i>전체펼치기</button>
										<button type="button" class="btn btn-default" onclick=AUIGrid.collapseAll(auiGridLeft);><i class="material-iconsremove text-default"></i>전체접기</button>
									</div>
								</div>
							</div>
							<div id="auiGridLeft"  style="margin-top: 5px;"></div>
						</div>
						<div class="col-8">
							<div class="title-wrap mt10">
								<h4>처리내역</h4>
								<div class="btn-group">
									<div class="right">
										<input type="checkbox" id="sub_org_apply_yn" name="sub_org_apply_yn" value="Y">
										<label for="sub_org_apply_yn" class="mr5">하위조직 일괄적용</label>
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
									</div>
								</div>
							</div>
							<div id="auiGridRight" style="margin-top: 5px;"></div>
						</div>
						<!-- 그리드 서머리, 컨트롤 영역 -->
						<div class="btn-group mt5">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
							</div>
						</div>
						<!-- /그리드 서머리, 컨트롤 영역 -->
					</div>
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>