<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-센터 > 실적분석 > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-08 11:47:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var filtered = true;
		var filterCols = [];
		var centerList = ${centerList};
		var numberFormat = "thousand";
		
		$(document).ready(function () {
			createAUIGrid1();	// 월별 매출
		});
		
		// 필터링
		function fnSetFilterToggle() {
			//  필터링 모두 해제
			if (filtered == true) {
				AUIGrid.clearFilterAll(auiGrid1);
				filtered = false;
			} else {
				AUIGrid.setFilter(auiGrid1, "col",  function(dataField, value, item) {
					return filterCols.indexOf(value) > -1 ? false : true; // 10 보다 큰 값만 출력 
				});
				filtered = true;
			}
		};
		
		function fnSetNumberFormatToggle() {
			if (numberFormat == "all") {
				numberFormat = "thousand";
			} else {
				numberFormat = "all"
			}
			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid1, true);
			colSizeList[0] = null;
 		    AUIGrid.setColumnSizeList(auiGrid1, colSizeList);
			AUIGrid.resize(auiGrid1);
		}

		// 조회
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			}

			// var month = $M.getValue("s_month");
			// if (month.toString().length == 1) {
			// 	month = '0' + month;
			// }
			var sStartYearMon = $M.getValue("s_start_year");
			var sStartMon = $M.getValue("s_start_mon")
			var sEndYearMon = $M.getValue("s_end_year");
			var sEndMon = $M.getValue("s_end_mon");

			if(sStartMon.length == 1) {
				sStartMon = "0" + sStartMon;
			}

			if(sEndMon.length == 1) {
				sEndMon = "0" + sEndMon;
			}

			sStartYearMon += sStartMon;
			sEndYearMon += sEndMon;

			if(sStartYearMon > sEndYearMon) {
				alert("시작년도가 종료년도보다 클 수 없습니다.");
				return;
			}

			var param = {
				// s_year: $M.getValue("s_year"),
				// s_year_mon: $M.getValue("s_year") + month,
				"s_start_year_mon" : sStartYearMon,
				"s_end_year_mon" : sEndYearMon
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
					function (result) {
						if (result.success) {
							destroyGrid();
							createAUIGrid1();
							var extractList = result.monSaleAmtList;

							if(extractList.length == 0) {
								alert("조회된 결과가 없습니다.");
								return;
							}
							console.log(result.headerAmtList);
							console.log(result.monSaleAmtList);

							var diffYear = $M.getValue("s_end_year") - $M.getValue("s_start_year");
							var diffMon = $M.getValue("s_end_mon") - $M.getValue("s_start_mon");

							// 검색한 기간
							var diff = diffYear * 12  + diffMon + 1;

							// 날짜 필터링
							for (var i = 0; i < diff; ++i) {
								filterCols.push(extractList[i].col);
							}
							
							var concats = [];
							concats = concats.concat(result.headerAmtList);
							concats = concats.concat([{col : "월별매출"}]);
							concats = concats.concat(result.monSaleAmtList);
							
							concats = concats.concat([{col : "월별수익"}]);
							concats = concats.concat(result.monProfitAmtList);
							concats = concats.concat([{col : "근무인원수"}]);
							concats = concats.concat(result.workMemList);
							concats = concats.concat([{col : "미수금"}]);
							concats = concats.concat(result.misuAmtList);
							
							AUIGrid.setGridData(auiGrid1, concats);

							if (filtered == false) {
								AUIGrid.clearFilterAll(auiGrid1);
							} else {
								AUIGrid.setFilter(auiGrid1, "col",  function(dataField, value, item) {
									return filterCols.indexOf(value) > -1 ? false : true; // 10 보다 큰 값만 출력 
								});
							}
							var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid1, true);
							colSizeList[0] = null;
				 		    AUIGrid.setColumnSizeList(auiGrid1, colSizeList);
							AUIGrid.resize(auiGrid1);
						}
					}
			);
		}

		// 센터별 분석설계 팝업
		function goCenterProfitPopup() {
			var poppupOption = "";
			$M.goNextPage('/serv/serv050203p01', "", {popupStatus: poppupOption});
		}

		// 분야별 집계 팝업
		function goTotalFieldPopup() {
			var poppupOption = "";
			var param = {
				"s_year": $M.getValue("s_end_mon") == '12' ? $M.toNum($M.getValue("s_end_year")) + 1 : $M.getValue("s_end_year"),
			}
			$M.goNextPage('/serv/serv050203p02', $M.toGetParam(param), {popupStatus: poppupOption});
		}

		// 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#auiGrid1");
			auiGrid1 = null;
		}

		// 기준정보 재생성
		function goChangeSave() {
			var s_year = $M.getValue("s_start_year");
        	var s_mon = $M.lpad($M.getValue("s_start_mon"), 2, '0');

            var param = {
                "s_year_mon": s_year + s_mon,
            };
            
            var msg = '일지 작성월 : ' + s_year + '/' + s_mon + ' ~ 당월 까지 정보를 재성성 합니다.\n실행하시겠습니까?'; 
			$M.goNextPageAjaxMsg(msg, "/serv/serv0502/change/save", $M.toGetParam(param), {method: "POST"},
					function (result) {
						if (result.success) {
							alert("기준정보 재생성을 완료하였습니다.");
							window.location.reload();
						}
					}
			);
		}

		// 월별매출
		function createAUIGrid1() {
			var gridPros = {
					/* headerHeight : 20,
					rowHeight : 11, 
					footerHeight : 20, */
				editable: false,
				enableFilter : true,
				rowIdField: "_$uid",
				showRowNumColumn: false,
				rowStyleFunction: function (rowIndex, item) {
					if (item.col.indexOf("1.") != -1 || item.col.indexOf("2.") != -1
							|| item.col.indexOf("3.") != -1 || item.col.indexOf("누계") != -1) {
						return "aui-grid-selection-row-satuday-bg"
					} else if (item.col.indexOf("월별") != -1 || item.col == "근무인원수" || item.col == "미수금") {
						return "aui-fold";
					} else if (item.col == "센터별 순수 이익" 
							|| item.col == "센터별 지출 대비 순익율" 
							|| item.col == "지출 비용 대비 순익"
							|| item.col == "센터별 순수 이익(지출 제외 순익)"
							|| item.col == "센터별 지출 대비 순익율(%)"
							|| item.col == "총미수금") {
						return "aui-grid-selection-row-sunday-bg";
					} 

					return "";
				}
			};

			var columnLayout = [
				{
					headerText: "구분",
					dataField: "col",
					width: "183",
					minWidth: "110",
				},
				{
					headerText: "합계",
					dataField: "total",
					style: "aui-right",
					width: "80",
					minWidth: "55",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all" || item.col == "센터별 근무 인원수" || item.col == "센터별 지출 대비 순익율(%)" || item.col == "(누적)익월대비 수익율 증감치(%)" 
								|| item.col == "전월까지의 순익율" || item.col == "전월까지의 순익율 증감치") {
								return $M.setComma(value);
							} else {
								return $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}
					}
				},
			]

			for (var i = 0; i < centerList.length; ++i) {
				var obj = {
					headerText: centerList[i].org_kor_name,
					dataField: centerList[i].field_name,
					style: "aui-right",
					width: "80",
					minWidth: "55",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all" || item.col == "센터별 근무 인원수" || item.col == "센터별 지출 대비 순익율(%)" || item.col == "(누적)익월대비 수익율 증감치(%)" 
								|| item.col == "전월까지의 순익율" || item.col == "전월까지의 순익율 증감치") {
								return $M.setComma(value);
							} else {
								return $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}
					}
				}
				
				if (obj.headerText == "부품") {
					obj = $.extend({
						headerTooltip : { // 헤더 툴팁 표시 HTML 양식
						    show : true,
						    tooltipHtml : '<div>부품부서 매출 = 부품판매현황-기간별 메뉴의 연간탭의 C+E, 부품부서 수익 = A3</div>'
						}
					}, obj);
				};

				columnLayout.push(obj);
			}

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid1 = AUIGrid.create("#auiGrid1", columnLayout, gridPros);

			// 그리드 갱신
			AUIGrid.setGridData(auiGrid1, []);
			
			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid1, true);
			colSizeList[0] = null;
 		    AUIGrid.setColumnSizeList(auiGrid1, colSizeList);
			
			$("#auiGrid1").resize();
		}
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid1, '서비스업무평가_센터_실적분석');
		}

	</script>
</head>
<body style="background : #fff">
	<form id="main_form" name="main_form">
		<div class="layout-box">
		<!-- contents 전체 영역 -->
			<div class="content-wrap">
				<div class="">
					<div class="">	
						<!-- 그리드 서머리, 컨트롤 영역 -->
						<%-- <div class="btn-group mt5">				
							<div class="right">							
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BASE_R"/></jsp:include>	
							</div>
						</div> --%>
					<!-- /그리드 서머리, 컨트롤 영역 -->	
			<!-- 검색영역 -->					
						<div class="search-wrap mt10">				
							<table class="table">
								<colgroup>							
									<col width="50px">
									<col width="270px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th>조회년도</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-auto">
													<select class="form-control" id="s_start_year" name="s_start_year">
														<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
															<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}" />
															<option value="${year_option}" <c:if test="${year_option eq inputParam.s_start_year}">selected</c:if>>${year_option}년</option>
														</c:forEach>
													</select>
												</div>
												<div class="col-auto">
													<select class="form-control" id="s_start_mon" name="s_start_mon">
														<c:forEach var="i" begin="1" end="12" step="1">
															<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_start_mon}">selected</c:if>>${i}월</option>
														</c:forEach>
													</select>
												</div>
												<div class="col-auto">~</div>
												<div class="col-auto">
													<select class="form-control" id="s_end_year" name="s_end_year">
														<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
															<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}" />
															<option value="${year_option}" <c:if test="${year_option eq inputParam.s_end_year}">selected</c:if>>${year_option}년</option>
														</c:forEach>
													</select>
												</div>
												<div class="col-auto">
													<select class="form-control" id="s_end_mon" name="s_end_mon">
														<c:forEach var="i" begin="1" end="12" step="1">
															<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_end_mon}">selected</c:if>>${i}월</option>
														</c:forEach>
													</select>
												</div>
											</div>
										</td>
										<td>
											<div class="btn-group">
												<div class="left">
													<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
												</div>				
												<div class="right">							
													<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BASE_R"/></jsp:include>	
												</div>
											</div>
										</td>									
									</tr>						
								</tbody>
							</table>					
						</div>
					<!-- /검색영역 -->										
					<!-- 그리드 타이틀, 컨트롤 영역 -->
						<div class="title-wrap mt10">
							<h4>실적분석</h4>
							<div class="btn-group">
								<div class="btn-group">
									<div class="left" style="margin-left:50px;">
										<span style="color: #ff7f00;">※ 기준일시 : ${lastStandDateTime}</span>
									</div>
									<div class="right">
										<label for="s_toggle_column" style="color:black;">
											<input type="checkbox" id="s_toggle_column" onclick="javascript:fnSetFilterToggle(event)">펼침
										</label>
										<label for="s_toggle_numberFormat" style="color:black;">
											<input type="checkbox" id="s_toggle_numberFormat" onclick="javascript:fnSetNumberFormatToggle(event)" checked="checked"><span>천</span> 단위
										</label>
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
									</div>
								</div>
							</div>
						</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->	
						<div id="auiGrid1" style="margin-top: 5px; height: 555px; width:100%;"></div>
					</div>
				</div>		
			</div>
		<!-- /contents 전체 영역 -->	
		</div>
	</form>	
</body>
</html>