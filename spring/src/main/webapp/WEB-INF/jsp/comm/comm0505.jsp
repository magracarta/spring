<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 결재선관리 > 업무일지 조회권한 관리 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-11-05 13:43:14
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createLeftAUIGrid();	
			createCenterAUIGrid();	
			createRightAUIGrid();	
		});
		
		var cellRowIndex = 0;	// 버튼권한 설정 후 셀클릭 위치지정
		
		// 그리드생성
		function createLeftAUIGrid() {
			var gridPros = {
				rowIdField : "rownum",
				showRowNumColumn : true,
				enableFilter :true,
				fillColumnSizeMode : false,
				height : 580
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "조직도",
				    dataField: "name",
				    filter : {
						showIcon : true
					},
					width : "80%",
					style : "aui-left"
				},
				{
					dataField : "code",
					visible : false
				},
				{
					dataField : "gubun",
					visible : false
				},
				{
					dataField : "mem_no",
					visible : false
				},
				{
					dataField : "rownum",
					visible : false
				},
			];
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridLeft, ${list});
			AUIGrid.expandItemByRowId(auiGridLeft, 1, true);
			
			// 클릭한 셀 데이터 받음
 			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
 				if (event.item.gubun == "MEM") {
 					var param = {
						"mem_no" : event.item["mem_no"]
					};
					// mem_no hidden에 저장
					var frm = document.main_form;
	 				$M.setValue(frm, "mem_no", param.mem_no);
					// 해당 부서 메뉴목록 검색
					// goSearchMenuList(param);
					goSearchViewList(param);
 				}
			});
		}
		
		function goSearchViewList(param) {
			AUIGrid.clearGridData(auiGridRight);
			console.log(param);
			$M.goNextPageAjax(this_page+"/search", $M.toGetParam(param), {method : "GET"},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGridRight, result.list);
						};
					}
				);
		}
		
		// 그리드생성
		function createCenterAUIGrid() {
			var gridPros = {
				rowIdField : "rownum",
				showRowNumColumn : true,
				enableFilter :true,
				fillColumnSizeMode : false,
				height : 580
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "조직도",
				    dataField: "name",
				    filter : {
						showIcon : true
					},
					width : "80%",
					style : "aui-left"
				},
				{
					dataField : "code",
					visible : false
				},
				{
					dataField : "gubun",
					visible : false
				},
				{
					dataField : "mem_no",
					visible : false
				},
				{
					dataField : "rownum",
					visible : false
				},
			];
			auiGridCenter = AUIGrid.create("#auiGridCenter", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridCenter, ${list});
			AUIGrid.expandItemByRowId(auiGridCenter, 1, true);
			// 클릭한 셀 데이터 받음
 			AUIGrid.bind(auiGridCenter, "cellClick", function(event) {
 				if (event.treeIcon == true) {
 					return false;
 				}
 				if ($M.getValue("mem_no") == "") {
 					alert("사용자를 선택하세요.");
 					return false;
 				}
 				var param = {
 					mem_no : $M.getValue("mem_no"),
 					org_code : event.item.code
 				};
 				var gubun = event.item.gubun;
 				if (gubun == "MEM") {
 					var isPass = true;
 					var list = AUIGrid.getGridData(auiGridRight);
 					for (var i = 0; i < list.length; ++i) {
 						if (list[i].view_mem_no == event.item.mem_no) {
 							alert("이미 추가되어 있습니다.");
 							isPass = false;
 							break;
 						}
 					}
 					if (event.item.mem_no == $M.getValue("mem_no")) {
 						alert("사용자를 적용할 수 없습니다.");
 						return false;
 					}
 					param["view_mem_no"] = event.item["mem_no"];
 					param["gubun"] = "MEM";
 					if (isPass = true) {
 						if (confirm(event.item.name+"을 추가하시겠습니까?") == false) {
 							return false;
 						} else {
 							goSave(param);
 						}
 					}
 				} else if (gubun == "ORG") {
 					param["gubun"] = "ORG";
 					if (confirm(event.item.name+"의 모든 직원을 추가하시겠습니까?(같은 뎁스만 적용됩니다.)") == false) {
						return false;
					} else {
						goSave(param);
					}
 				}
			});
		}
		
		// 그리드생성
		function createRightAUIGrid() {
			var gridPros = {
				fillColumnSizeMode : false,
				height : 580
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "부서",
					dataField : "org_name",
					style : "aui-center",
				},
				{
					headerText : "이름",
					dataField : "grant_name",
					style : "aui-center",
				},
				{
					headerText : "보기/숨기기",
					dataField : "view_yn",
					labelFunction : function(rowIndex, columnIndex, value) {
						return value == "Y" ? "조회" : "숨기기";
					},
				},
				{
					headerText : "편집",
					labelFunction : function(rowIndex, columnIndex, value){
						return "삭제";
					},
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							if (event.item.view_mem_no == $M.getValue("mem_no")) {
								alert("본인을 삭제할 수 없습니다.");
		 						return false;
							}
							var param = {
								mem_no : event.item.mem_no,
								view_mem_no : event.item.view_mem_no
							};
							$M.goNextPageAjaxRemove(this_page+"/remove", $M.toGetParam(param), {method : "POST"},
									function(result) {
										if(result.success) {
											AUIGrid.removeRow(event.pid, event.rowIndex);	
											AUIGrid.removeSoftRows(auiGridRight);
											AUIGrid.resetUpdatedItems(auiGridRight);
										};
									}
								);
						},
					},
				},
				{
					dataField : "mem_no",
					visible : false
				},
				{
					dataField : "view_mem_no",
					visible : false
				}
			];
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRight, []);
		}
		
		function goSave(param) {
			$M.goNextPageAjax(this_page+"/save", $M.toGetParam(param), {method : "POST"},
				function(result) {
					if(result.success) {
						alert("저장이 완료되었습니다.");
						var params = {
							mem_no : $M.getValue("mem_no")
						}
						goSearchViewList(params);
					};
				}
			);
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<input type="hidden" id="mem_no" name="mem_no">
	<!-- contents 전체 영역 -->
	<div class="content-wrap" style="height: 700px;">
		<div class="content-box">
			<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /메인 타이틀 -->
			<div class="contents">
				<div class="row">
					<div class="col-4">
						<div class="title-wrap mt10">
							<h4>사용자</h4>
						</div>
						<!-- 그리드 생성 -->
						<div id="auiGridLeft" style="margin-top: 5px;"></div>
					</div>
					<div class="col-4">
						<div class="title-wrap mt10">
							<h4>조회대상</h4>		
						</div>
						<!-- 그리드 생성 -->
						<div id="auiGridCenter" style="margin-top: 5px;"></div>
					</div>
					<div class="col-4">
						<div class="title-wrap mt10">
							<h4>적용결과</h4>		
						</div>
						<!-- 그리드 생성 -->
						<div id="auiGridRight" style="margin-top: 5px;"></div>
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