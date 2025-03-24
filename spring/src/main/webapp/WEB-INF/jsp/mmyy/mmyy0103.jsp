<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지(관리계정) > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-06-26 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>

	<script type="text/javascript">
	var auiGrid;
	var workCalList;
	
	// 동적 셀 스타일 맵
	var styleMap = {};
	
	// 영업, 관리, 서비스, 부품, 나머지
	
	$(document).ready(function () {
		if( "${inputParam.s_year_mon}" == "" || "${inputParam.s_year_mon}" == undefined){
			$M.setValue("s_year_mon", "${inputParam.s_current_mon}");
		}
		
		fnInit();
		createAUIGrid();
		goSearch();
	});

	function fnInit() {
		workCalList = ${workCalList};
	}
	
	// 셀 스타일 함수
	function myCellStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField) {
		var key = item._$uid + "-" + dataField;
		if(typeof styleMap[key] != "undefined") {
			return styleMap[key];
		}
		return null;
	};
	
	function createAUIGrid() {
		var gridPros = {
			displayTreeOpen :true,
			rowCheckDependingTree : true,
			showRowNumColumn: false,	
			rowIdField : "_$uid",
			editable : false,	
			// 워드랩 적용 안함(기본값 : false) 
			wordWrap : false, 			
			// 고정할 행 높이
			rowHeight : 42
		};

		var columnLayout = [	
			{
				headerText : "조직도",
				dataField : "kor_name",
				minWidth : "100",
				width : "220"
			},
			{
				headerText : "직원번호", 
				dataField : "mem_no", 
				editable : false,
				visible:false
			}			
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

		//업무달력그리기
		for (var i = 0; i < workCalList.length; ++i) {
			var result = workCalList[i];
			var workDt = result.work_dt;
			var week = result.week;
			var today_yn = result.today_yn;
			var holi_yn = result.holi_yn;
			var mon = result.work_dt.substr(4,2);
			var day = result.work_dt.substr(6,2);
			var header = $M.toNum(mon) + "/" + $M.toNum(day);

			var style = "aui-center aui-pointer"
			if(week == 1){
				style += " aui-calendar-saturday-bg";
			}
			else if(week == 7){
				style += " aui-calendar-sunday-bg";
			}
			else if(today_yn == "Y"){
				style += " aui-calendar-today-bg";
			}
			else if(holi_yn == "Y"){
				style += " aui-calendar-holiday-bg";
			}			
			else {
				style= "aui-center aui-pointer";
			}
			
			var columnObj = {				
					
					headerText : header,
					children :[
						{
							headerText : result.week_name,
							dataField :  result.colday,
							style : style,
							renderer : { // HTML 템플릿 렌더러 사용
								type : "TemplateRenderer"
							}, 
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								
								var rtnValue = value;
								if(rtnValue != "" && rtnValue != undefined ){
							
									if (rtnValue.indexOf('Y') != -1) {
										rtnValue = "<p style='color: gray;text-decoration: underline; text-underline-position: under;'>" + rtnValue + "</p>";
									}
									rtnValue = rtnValue.replace('N','').replace('Y','');
								}
								else {
									rtnValue = "";
								}
							    return  rtnValue;
							},
							minWidth : "45",
							width : "5%",
							styleFunction :  myCellStyleFunction
						}
					]				
			}
			AUIGrid.addColumn(auiGrid, columnObj, 'last');
		}
		$("#auiGrid").resize();

		//// AUIGrid.setFixedColumnCount(auiGrid, 10);
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if (event.columnIndex != 0) {
				var selItems = AUIGrid.getSelectedItems(auiGrid);
				var item, key;
				for(var i=0, len=selItems.length; i<len; i++) {
					item = selItems[i];
					key = item.rowIdValue + "-" + item.dataField;
					styleMap[key] = "aui-visited";
				}
				// 그리드 갱신
				console.log(styleMap[key]);
				AUIGrid.update(auiGrid);
			}
			//부서별 업무일지 상세 페이지 분기처리
			if(event.item.org_code != "" 
					&& event.item.org_code != undefined  
					&&  event.dataField != "kor_name"
					&& event.item.mem_no != undefined)
			{
				var dt = $M.getValue("s_search_dt");
				var len = workCalList.length;
				for (var i = 0; i < len; ++i) {
					if (workCalList[i].colday == event.dataField) {
						dt = workCalList[i].work_dt;
						break;
					}
				}
				var param = {
					"s_mem_no" : event.item.mem_no,
					"s_work_dt" : dt
				};
				var org_gubun = event.item.org_code.substr( 0, 1);
				//서비스부, 기획부(김태공상무님 부서, 20210302)
				if(org_gubun == "5" || org_gubun == "8"){
					var poppupOption = "";

					var params = {
						"s_mem_no" : event.item.mem_no
					};

					$M.goNextPageAjax(this_page + "/auth/check", $M.toGetParam(params), {method: "GET"},
						function (result) {
							if (result.success) {
								if (result.auth_yn == 'Y') { // 서비스관리,서비스부서장만 해당
									param["s_org_code"] = event.item.org_code;
									param["mng_yn"] = "Y";
									console.log(result);
									$M.goNextPage('/mmyy/mmyy0103p06', $M.toGetParam(param), {popupStatus : poppupOption});
								} else {
									$M.goNextPage('/mmyy/mmyy0103p01', $M.toGetParam(param), {popupStatus : poppupOption});
								}
							}
						}
					);

					// $M.goNextPage('/mmyy/mmyy0103p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
				//영업부,경영지원부 (Q&A 21367. 경영지원부 업무일지상세-관리부로 보여지도록 수정 요청)
				else if(org_gubun == "4" || org_gubun == "3"){
					var poppupOption = "";
					$M.goNextPage('/mmyy/mmyy0103p02', $M.toGetParam(param), {popupStatus : poppupOption});
				}
				//관리부
				else if(org_gubun == "2"){
					var poppupOption = "";
					$M.goNextPage('/mmyy/mmyy0103p03', $M.toGetParam(param), {popupStatus : poppupOption});
				}				
				//부품부
				else if(org_gubun == "6" ){
					var poppupOption = "";
					$M.goNextPage('/mmyy/mmyy0103p04', $M.toGetParam(param), {popupStatus : poppupOption});
				}
				//나머지 직원은 관리부로 표시 
				else {
					var poppupOption = "";
					$M.goNextPage('/mmyy/mmyy0103p03', $M.toGetParam(param), {popupStatus : poppupOption});
				}
				$("#auiGrid").resize();
			}
		});
	}
	
	// 셀렉트박스 변경 시
	function fnDtChange() {
		if ($M.getValue("s_search_dt") != "") {
			goSearch();
		}
	}
	
	
	function goSearch() {
		var param = {
				"s_search_dt" : $M.getValue("s_search_dt"),
				"s_kor_name" : $M.getValue("s_kor_name")
			};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
			function (result) {
				if (result.success) {				
					workCalList = result.workCalList;
					destroyGrid();					
					createAUIGrid();
					AUIGrid.setGridData(auiGrid, result.treeList);
					 //만약칼럼사이즈들의총합이그리드크기보다작다면,나머지값들을나눠가져그리드크기에맞추기
					/* var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid,true);
					   
					   //구해진칼럼사이즈를적용시킴.
					AUIGrid.setColumnSizeList(auiGrid,colSizeList); */
				}
			}
		);
	}
	
	// 그리드 초기화
	function destroyGrid() {
		AUIGrid.destroy("#auiGrid");
		auiGrid = null;
	}
	
	
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_kor_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
	}
	
	
	// 엑셀 다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGrid, "업무일지(관리)");
	}
	
	function goDiaryShowAndHide() {
		var param = {
			mem_no : "${SecureUser.mem_no}"
		}
		var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1450, height=850, left=0, top=0";
		$M.goNextPage('/mmyy/mmyy0103p05', $M.toGetParam(param), {popupStatus : poppupOption});
	}
	
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="s_year_mon" name="s_year_mon" value="${inputParam.s_year_mon}" />
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
	<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
	<!-- /메인 타이틀 -->
			<div class="contents" style="width: 55%">
	<!-- 기본 -->
				<div class="search-wrap">
					<table class="table table-fixed">
						<colgroup>
							<col width="60px">
							<col width="110px">
							<col width="55px">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th>조회일자</th>
							<td>
								<div class="form-row inline-pd" style="padding-left: 10px;">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_search_dt" name="s_search_dt" dateFormat="yyyy-MM-dd"  value="${inputParam.s_current_dt }" alt="요청 시작일" onchange="fnDtChange()">
									</div>
								</div>
							</td>
							<th>사원명</th>
							<td>
								<input type="text" class="form-control" id="s_kor_name" name="s_kor_name" >
							</td>
							<td>
								<button type="button" class="btn btn-important"  style="width: 50px;" onclick="javascript:goSearch();">조회</button>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
	<!-- /기본 -->	
	<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>업무일지내역</h4>
					<div class="btn-group">
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
							<button type="button" class="btn btn-default" onclick="javascript:goDiaryShowAndHide()">보이기/감추기</button>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div id="auiGrid" style="margin-top: 5px; height: 550px; width: 100%"></div>
			</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>