<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품호환성관리 > null > 전체호환부품목록
-- 작성자 : 박예진
-- 최초 작성일 : 2021-07-15 18:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		var auiGrid;
		var mchListJson = ${mchListJson};
		$(document).ready(function() {
			// AUIGrid 생성
			createauiGrid();		
			goSearch();
		});

		// 조회
		function goSearch() {
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result){
				fnResult(result);
// 				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}
		
		function fnSearch(successFunc) {
			isLoading = true;
			var param = {
					"maker_cd" : $M.getValue("maker_cd"),
					"s_sale_yn" : $M.getValue("s_sale_yn") == "Y" ? "Y" : "N",
					"s_yk_sale_yn" : $M.getValue("s_yk_sale_yn") == "Y" ? "Y" : "N",
					"page" : page,
					"rows" : $M.getValue("s_rows")
			}

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
				function (result) {
					isLoading = false;
					if(result.success) {
						successFunc(result);
					};
				}
			);
		}
		
		function fnResult(result) {
			var columnLayout = [
				{
					headerText : "부품번호",
					dataField : "part_no",
					style : "aui-center",
					width : "150",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "부품명",
					dataField : "part_name",
					style : "aui-left",
					width : "180",
					filter : {
						showIcon : true
					}
				},
// 				{
// 					headerText: "수량",
// 					dataField: "total_qty",
// 					width: "60",
// 					minWidth: "60",
// 					style : "aui-right",
// 					dataType : "numeric",
// 					formatString : "#,##0",
// 				},
			];
			
			var mchList = result.mchListJson;

			for(var i=0; i < mchList.length; i++) {
				var headerTextName = mchList[i].machine_name;
				var dataFieldName = "a_" + mchList[i].machine_plant_seq + "_yn";

				var machineNameObj = {
					headerText: headerTextName,
					dataField: dataFieldName,
					width: "90",
					minWidth: "90",
					style: "aui-center",
				}

				columnLayout.push(machineNameObj);
			}
			

			var qtyObj = {
					headerText: "수량",
					dataField: "total_qty",
					width: "60",
					minWidth: "60",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
			}
				
			columnLayout.push(qtyObj);
			
			AUIGrid.changeColumnLayout(auiGrid, columnLayout);
			AUIGrid.setGridData(auiGrid, result.list);
				

			$("#auiGrid").resize();
		}
		
		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
				goMoreData();
			};
		}
		
		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;  
				if (result.list.length > 0) {
					console.log(result.list);
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				};
			});
		}
		
		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "전체호환부품목록", "");
		}
	
		// 닫기
		function fnClose() {
			window.close(); 
		}	
		
		// 작업지시 그리드
		function createauiGrid() {
			var gridPros = {
				editable : false,
				rowIdField : "_$uid", 
				showRowNumColumn : true,
				enableFilter :true,
			};
			
			var columnLayout = [];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
			$("#auiGrid").resize();
		}
	
	</script>
</head>
<body class="bg-white">
	<form id="main_form" name="main_form">
	<input type="hidden" name="maker_cd" id="maker_cd" value="${inputParam.maker_cd}">
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
				<!-- 폼테이블 -->
				<div>
					<div class="title-wrap">
						<div class="left" style="width:80%;"><h4>${makerName}</h4></div>
						<div class="btn-group">
							<div class="right">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="s_sale_yn" name="s_sale_yn" value="Y" checked="checked" onChange="javascript:goSearch();">
									<label class="form-check-input" for="s_sale_yn">판매중</label>
									<input class="form-check-input" type="checkbox" id="s_yk_sale_yn" name="s_yk_sale_yn" value="Y" checked="checked" onChange="javascript:goSearch();">
									<label class="form-check-input" for="s_yk_sale_yn">YK취급모델</label>
								</div>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R" /></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGrid" style="margin-top: 5px; height: 700px;"></div>
				</div>
				<!-- /폼테이블-->
				<div class="btn-group mt10">
					<div class="left">
						<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
					</div>									
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
				</div>
			</div>
		</div>
		<!-- /팝업 -->
	</form>
</body>
</html>