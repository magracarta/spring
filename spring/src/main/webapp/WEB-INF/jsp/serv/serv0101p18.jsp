<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 정비불러오기
-- 작성자 : 이강원
-- 최초 작성일 : 2023-03-30 11:50:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var auiGrid;
	
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();
		goSearch();
	});

	function goSearch() {
		var params = {
			"s_machine_plant_seq" : $M.getValue("s_machine_plant_seq")
		};

		$M.goNextPageAjax(this_page + '/search', $M.toGetParam(params), {method : 'GET'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGrid, result.list);
					AUIGrid.expandAll(auiGrid);
				}
			}
		);
	}

	// 펼침
	function fnExpandAll() {
		AUIGrid.expandAll(auiGrid);
	}
	// 접힘
	function fnCollapseAll() {
		AUIGrid.collapseAll(auiGrid);
	}
	
	// function goApplyInfo() {
	function goApply() {
		// 체크된 그리드 데이터
		var itemArr = AUIGrid.getCheckedRowItems(auiGrid);

		// getCheckedRowItems로 data를 가져올 때 rowIndex 순서대로 가져오지 않기 때문에 한 번더 rowIndex 기준으로 정렬
		var sortedData = itemArr.sort(function(a, b) {
			return a.rowIndex - b.rowIndex;
		});

		if(sortedData.length == 0) {
			alert("적용할 데이터를 체크해주세요.");
			return;
		}

		try {
			opener.${inputParam.parent_js_name}(sortedData);
			window.close();
		} catch(e) {
			alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
		}
	}

	// 닫기
	function fnClose() {
		window.close();
	}

	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "job_order_bookmark_seq",
			showRowNumColumn: true,
			// 체크박스 출력 여부
			showRowCheckColumn : true,
			// 전체선택 체크박스 표시 여부
			showRowAllCheckBox : true,
			rowCheckDependingTree : true,
			treeColumnIndex : 0,
			rowCheckDisabledFunction: function (rowIndex, isChecked, item) {
				// 그룹명이 아닌경우 체크 불가
				if (item.group_yn =='N') {
					return false;
				}

				return true;
			},
			enableFilter :true,
			showFooter : true,
		};
		var columnLayout = [
			{
				headerText : "그룹명/정비내용",
				dataField : "order_text",
				width : "50%",
				style : "aui-left",
				filter : {
					showIcon : true
				}
			},
			{ 
				headerText : "예상비용",
				dataField : "plan_work_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					if (value == 0) {
						return "";
					}
					return AUIGrid.formatNumber(value, "#,##0");
				},
				filter : {
					showIcon : true
				}
			},
			{ 
				headerText : "시간", 
				dataField : "work_hour",
				style : "aui-center",
				dataType : "numeric",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					if (value == 0) {
						return "";
					}
					return value;
				},
				filter : {
					showIcon : true
				}
			},
			{ 
				headerText : "사용여부", 
				dataField : "use_yn",
				style : "aui-center",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					if (item.group_yn != 'Y') {
						return "";
					}
					return value == "Y" ? "사용" : "미사용";
				},
				filter : {
					showIcon : true
				}
			},
			{ 
				headerText : "정렬순서", 
				dataField : "sort_no",
				style : "aui-center",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					if (item.group_yn != 'Y') {
						return "";
					}
					return value;
				},
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "지시번호",
				dataField : "job_order_bookmark_seq",
				visible : false
			},
			{
				headerText : "상위지시번호",
				dataField : "up_job_order_bookmark_seq",
				visible : false
			},
			{
				headerText : "작업구분",
				dataField : "boobmark_type_jr",
				visible : false
			},
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		$("#auiGrid").resize();

		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "order_text") {
				const item = event.item;
				const rowIdField = AUIGrid.getProp(event.pid, "rowIdField"); // rowIdField 얻기
				const rowId = item[rowIdField];
				let idArr = [];
				let parent = AUIGrid.getParentItemByRowId(event.pid, rowId);
				let child = item.hasOwnProperty("children") ? item['children'] : [];
				let check = AUIGrid.isCheckedRowById(event.pid, rowId);

				idArr.push(rowId);
				for(let i = 0; i < child.length; i++) {
					let childItem = child[i];
					idArr.push(childItem[rowIdField]);
				}

				// 이미 체크 선택되었는지 검사
				if(check) {
					// 엑스트라 체크박스 체크해제 추가
					AUIGrid.addUncheckedRowsByIds(event.pid, idArr);
				} else {
					if(parent != null) {
						idArr.push(parent[rowIdField]);
					}
					// 엑스트라 체크박스 체크 추가
					AUIGrid.addCheckedRowsByIds(event.pid, idArr);
				}
			}
		})

		AUIGrid.bind(auiGrid, "rowCheckClick", function(event) {
			const rowIdField = AUIGrid.getProp(event.pid, "rowIdField"); // rowIdField 얻기
			let child = event.item.hasOwnProperty("children") ? event.item['children'] : [];
			let idArr = [];
			for(let i = 0; i < child.length; i++) {
				let childItem = child[i];
				idArr.push(childItem[rowIdField]);
			}
			idArr.push(event.item[rowIdField]);

			if(event.checked) {
				AUIGrid.addCheckedRowsByIds(event.pid, idArr);
			} else {
				AUIGrid.addUncheckedRowsByIds(event.pid, idArr);
			}
		});
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="s_machine_plant_seq" name="s_machine_plant_seq" value="${inputParam.s_machine_plant_seq}"/>
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">					
			<div>
<!-- 자주 쓰는 작업 -->
				<div class="row">
					<div class="col-12">
<!-- 상담과 점검/정비 -->		
						<div class="title-wrap">
							<div class="left">
								<h4>정비목록</h4>
							</div>
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
							</div>
						</div>
						<div id="auiGrid" style="margin-top: 5px; height: 507px;"></div>
<!-- /상담과 점검/정비 -->
						<div class="btn-group mt10">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
							</div>
						</div>
<!-- /그룹별 상담/점검/정비설정 -->
					</div>					
				</div>
<!-- /자주 쓰는 작업 -->
			</div>		
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>