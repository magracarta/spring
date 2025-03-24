<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무 > 인사일정관리 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-03-04 13:25:41
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
		});

		function createAUIGrid() {

			var gridPros = {
				rowIdField: "_$uid",
				wrapSelectionMove: false,
				showRowNumColumn: false,
				editable: false,
				enableCellMerge: true,
				cellMergeRowSpan: true,
				rowStyleFunction: function (rowIndex, item) {
					if (item.week_name == "일요일") {
						return "aui-grid-selection-row-sunday-bg"
					} else if (item.week_name == "토요일") {
						return "aui-grid-selection-row-satuday-bg"
					}
					return "";
				}
		};

		var columnLayout = [
				{
					headerText : "년도",
					dataField : "current_year",
					width : "6%",
					style : "aui-center",
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "current_mon", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict"
				},
				{
					headerText : "월-일",
					dataField : "current_mon",
					width : "5%",
					style : "aui-center",
					cellMerge : true
				},
				{
					headerText : "요일",
					dataField : "week_name",
					width : "6%",
					style : "aui-center",
					cellMerge : true
				},
				{
					headerText : "요청자",
					dataField : "mem_name",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "일정구분",
					dataField : "holiday_type_name",
					width : "5%",
					style : "aui-center"
				},
				{
					headerText : "일정기간",
					dataField : "schedule_term",
					width : "20%",
					style : "aui-center"
				},
				{
					headerText : "내용",
					dataField : "content",
					width : "40%",
					style : "aui-center"
				},
				{
					headerText : "행사명",
					dataField : "event_name",
					width : "8%",
					style : "aui-center"
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
		}

		// 셀렉트박스 변경 시
		function yearMonChange() {
			var sYear = $M.getValue("s_year");
			var sMon = $M.getValue("s_mon")

			if(sMon.length == 1) {
				sMon = "0" + sMon;
			}

			var sYearMon = sYear + sMon;
			$M.setValue("s_year_mon", $M.dateFormat($M.toDate(sYearMon), 'yyyyMM'));
			goSearch();
		}

		// 조회
		function goSearch() {
			var param = {
				"s_year_mon" : $M.getValue("s_year_mon"),
				"s_kor_name" : $M.getValue("s_kor_name")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}

		// 엔터 이벤트
		function enter(fieldObj) {
			var field = ["s_kor_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}

		// 엑셀 다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "인사일정관리");
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
			<div class="contents">
				<!-- 검색영역 -->
				<div class="search-wrap mt10">				
					<table class="table table-fixed">
						<colgroup>
							<col width="60px">
							<col width="150px">								
							<col width="55px">
							<col width="150px">		
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>조회년월</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-7">
											<select class="form-control" id="s_year" name="s_year" onchange="javascript:yearMonChange()">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year+1}" step="1">
													<option value="${i}" <c:if test="${i==inputParam.s_year}">selected</c:if>>${i}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-5">
											<select class="form-control" id="s_mon" name="s_mon" onchange="javascript:yearMonChange()">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>	
								<th>사용자</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control" id="s_kor_name" name="s_kor_name">
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important" onclick="javascript:goSearch()" style="width: 50px;">조회</button>
								</td>									
							</tr>						
						</tbody>
					</table>					
				</div>
				<!-- /검색영역 -->
				<!-- 조회결과 영역-->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
						</div>
					</div>
				</div>
				<div id="auiGrid" class="mt10" style="margin-top: 5px; height: 500px;"></div>
				<!-- /조회결과 영역-->
			</div>
		</div>		
	</div>
<!-- /contents 전체 영역 -->
</div>	
</form>
</body>
</html>