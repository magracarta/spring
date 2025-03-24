<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 생산/선적오더관리 > 어테치먼트 발주관리 > 어테치먼트 발주관리-영업 > null
-- 작성자 : 임예린
-- 최초 작성일 : 2021-08-11 12:00:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();
			goSearch();
		});
		
		// 조회
		function goSearch() {
			if($M.getValue("s_maker_cd") == "") {
				alert('메이커를 선택해 주세요.');
				return;
			}
			var param = {
				"s_maker_cd" : $M.getValue("s_maker_cd"),
				"s_start_mon" : $M.getValue("s_start_year")+$M.getValue("s_start_mon").padStart(2,'0'),
				"s_end_mon" : $M.getValue("s_end_year")+$M.getValue("s_end_mon").padStart(2,'0')
			};
			header = [];
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {
				method : "GET"
			}, function(result) {
				if(result.success) {
					if(result.header != null && result.header.length > 0 ) {
						fnResult(result);
					}
				}
			});
		}

		// 받아온 데이터로 그리드 세팅
		function fnResult(result) {
			var columnLayout = [ 
				{
					headerText : "생산모델",
					dataField : "machine_lc_no",
					colSpan : 3,
					cellColMerge: true, // 셀 가로병합
                    cellColSpan: 3, // 셀 가로병합
                    cellMerge: true, // 셀 세로병합
                    width: "100",
                    minWidth: "30",
                    renderer : {
			            type : "TemplateRenderer",
			     	},
				}, 
				{
					dataField : "ship_dt",
					width: "100",
                    minWidth: "30",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if (!isNaN(value)) {
							value = $M.dateFormat(value, 'yyyy-MM-dd');
						};
						return value;
					},
				}, 
				{
					dataField : "in_plan_dt",
					width: "100",
                    minWidth: "30",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if (!isNaN(value)) {
							value = $M.dateFormat(value, 'yyyy-MM-dd');
						};
						return value;
					},
				}, 
				{
					headerText : "",
					dataField : "total",
					style : "aui-left",
					children : [ {
						headerText : "대수합계",
						dataField : "mch_total",
						style : "aui-center",
						width: "100",
						minWidth: "50",
						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
							return value == 0 ? "" : $M.setComma(value);
						}
					} ]
				}, 
				{
					headerText : "모델 별 생산/선적 오더 대수",
					dataField : "models",
					style : "aui-left",
					children : []		// (Q&A 12742) 이진동님 요청으로 틀고정 추가 21.09.29 박예진
				}, 
				{
					headerText : "입고센터",
					dataField : "in_center_name",
					width: "100",
					minWidth: "50",
					style : "aui-center"
				}, 
				{
					headerText : "컨테이너 수",
					dataField : "container_cnt",
					width: "100",
					minWidth: "50",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value == 0 ? "" : $M.setComma(value);
					}
				}];
			
			//모델 별 생산/선적 오더 대수에 장비명 추가
			for (var i = 0; i < result.header.length; ++i) {
				var child = {
					dataField : result.header[i].header_seq,
					headerText : result.header[i].machine_name,
					width: "100",
					minWidth: "50",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value == 0 ? "" : (isNaN(value) ? value : $M.setComma(value));
					},
				}
				columnLayout[4].children.push(child);
			}
			console.log(result.list);
			AUIGrid.changeColumnLayout(auiGrid, initColumnLayout(columnLayout));
			AUIGrid.setGridData(auiGrid, result.list);
			AUIGrid.setFixedColumnCount(auiGrid, 4);	// (Q&A 12742) 이진동님 요청으로 틀고정 추가 21.09.29 박예진
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				height: 515,
				showHeader : true,
				enableSorting : false,
				showRowNumColumn: true,
				enableCellMerge: true, // 셀병합 사용여부
				cellMergeRowSpan: true,
	            editableOnFixedCell : true, // (Q&A 12742) 이진동님 요청으로 틀고정 추가 21.09.29 박예진
				editable : false,
				rowIdField : "_$uid",
				headerHeight : 35,
				// 고정칼럼 카운트 지정
			};
			
			// 컬럼레이아웃
			var columnLayout = [];
			
			auiGrid = AUIGrid.create("#auiGrid", initColumnLayout(columnLayout), gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "어테치먼트 발주관리-마케팅", "");
		}
		
		//날짜 초과 시 데이터 맞춤
		function fnChangeMon() {
			var s_start_mon = $M.getValue("s_start_year")+$M.getValue("s_start_mon").padStart(2,'0');
			var s_end_mon = $M.getValue("s_end_year")+$M.getValue("s_end_mon").padStart(2,'0');
			if(s_start_mon > s_end_mon) {
				$M.setValue("s_end_year", $M.getValue("s_start_year"));
				$M.setValue("s_end_mon", $M.getValue("s_start_mon"));
			}
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
<!-- 검색영역 -->		
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="140px">		
								<col width="20px">
								<col width="140px">				
								<col width="60px">
								<col width="90px">				
								<col width="">
							</colgroup>
							<tbody>
								<tr>								
									<th>조회년월</th>
									<td>		
										<div class="form-row inline-pd" onChange="javascript:fnChangeMon();">							
											<div class="col-7">
												<jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
													<jsp:param name="year_name" value="s_start_year"/>
													<jsp:param name="sort_type" value="d"/>
													<jsp:param name="select_year" value="${inputParam.s_start_year}"/>
												</jsp:include>
											</div>
											<div class="col-5">
												<select class="form-control" id="s_start_mon" name="s_start_mon" >
													<c:forEach var="i" begin="01" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i == inputParam.s_start_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<td class="text-center">~</td>
									<td>
										<div class="form-row inline-pd">							
											<div class="col-7">
												<jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
													<jsp:param name="year_name" value="s_end_year"/>
													<jsp:param name="sort_type" value="d"/>
													<jsp:param name="select_year" value="${inputParam.s_end_year}"/>
													<jsp:param name="max_year" value="${inputParam.s_end_year}"/>
												</jsp:include>
											</div>
											<div class="col-5">
												<select class="form-control" id="s_end_mon" name="s_end_mon">
													<c:forEach var="i" begin="01" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i == inputParam.s_end_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<th>메이커</th>
									<td>
										<select id="s_maker_cd" name="s_maker_cd" class="form-control">
											<c:forEach items="${codeMap['MAKER']}" var="item">
												<c:if test="${item.code_v2 == 'Y'}">
													<option value="${item.code_value}">${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();" >조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>						
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>						
			</div>		
<!-- /contents 전체 영역 -->	
</form>
</body>
</html>