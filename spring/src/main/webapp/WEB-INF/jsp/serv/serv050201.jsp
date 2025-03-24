<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-센터 > 집계표 > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-08 11:39:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var centerList = ${centerList};
		var centerCd = [];
		var numberFormat = "thousand";

		$(document).ready(function () {
			createAUIGrid();
		});

		function fnSetNumberFormatToggle() {
			if (numberFormat == "all") {
				numberFormat = "thousand";
			} else {
				numberFormat = "all"
			}

			console.log(numberFormat);
			AUIGrid.resize(auiGrid);
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

		// 집계표 목록 조회
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			}

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
				"s_start_year_mon" : sStartYearMon,
				"s_end_year_mon" : sEndYearMon
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
					function (result) {
						if (result.success) {
							if(typeof result.list != "undefined") {
								AUIGrid.setGridData(auiGrid, result.list);
							} else {
								alert("조회된 결과가 없습니다.");
								AUIGrid.clearGridData(auiGrid);
							}
						}
					}
			);
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: false,
				rowStyleFunction: function (rowIndex, item) {
					if (item.col.indexOf("누계") != -1 || item.col.indexOf("순익율 증감치") != -1
							|| item.col.indexOf("전월까지의 순익율") != -1) {
						return "aui-grid-selection-row-satuday-bg"
					} else if(item.col.indexOf("최종 순익") != -1 || item.col.indexOf("순익율") != -1) {
						return "aui-grid-selection-row-sunday-bg";
					}

					return "";
				}
			};

			var columnLayout = [
				{
					headerText: "집계내역",
					dataField: "col",
					width : "140",
					minWidth : "130",
				},
				{
					headerText: "합계",
					dataField: "total",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right",
					width : "80",
					minWidth : "70",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (value == "0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all" || item.col == "순익율" || item.col == "수익율 증감치" || item.col == "MBO달성율" 
								|| item.col == "전월까지의 순익율" || item.col == "전월까지의 순익율 증감치" || item.col == "근무인원(수습제외)") {
								if (item.col == "순익율" || item.col == "수익율 증감치" || item.col == "MBO달성율" || item.col == "전월까지의 순익율") {
									console.log(item.col);
									return value + "%";
								} else {
									return $M.setComma(value);
								}
							} else {
								return $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}
					}
				},
			];


			for (var i = 0; i < centerList.length; ++i) {
				var obj1 = {
					headerText: centerList[i].org_kor_name,
					dataField: centerList[i].field_name,
					style: "aui-right",
					dataType: "numeric",
					formatString: "#,##0",
					width : "70",
					minWidth : "60",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (value == "0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all" || item.col == "순익율" || item.col == "수익율 증감치" || item.col == "MBO달성율" 
								|| item.col == "전월까지의 순익율" || item.col == "전월까지의 순익율 증감치" || item.col == "근무인원(수습제외)") {
								if (item.col == "순익율" || item.col == "수익율 증감치" || item.col == "MBO달성율" || item.col == "전월까지의 순익율") {
									return value + "%";
								} else {
									return $M.setComma(value);
								}
							} else {
								return $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}
					}
				}
				
				var obj2 = {
					headerText: "비율",
					dataField: centerList[i].field_name + "_per",
					style: "aui-center",
					dataType: "numeric",
					formatString: "#,##0",
					width : "60",
					minWidth : "50",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						console.log(isNaN(value));
						if (value == "0" || value == ""  || value == null || isNaN(value)) {
							return "";
						} else {
							return value + "%";
						}
					}
				}

				columnLayout.push(obj1);
				columnLayout.push(obj2);
				centerCd.push(centerList[i].field_name);
			}

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
		}

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '서비스업무평가-센터-집계표');
		}

		// 기준정보 재생성
		function goChangeSave() {
			var s_year = $M.getValue("s_start_year");
        	var s_mon = $M.lpad($M.getValue("s_start_mon"), 2, '0');

            var param = {
                "s_year_mon": s_year + s_mon,
            };
            
            var msg = '일지 작성월 : ' + s_year + '/' + s_mon + ' ~ 당월 까지 정보를 재성성 합니다.\n실행하시겠습니까?'; 
			$M.goNextPageAjaxMsg(msg, "/serv/serv0501/change/save", $M.toGetParam(param), {method: "POST", timeout : 60 * 60 * 1000},
					function (result) {
						if (result.success) {
							alert("기준정보 재생성을 완료하였습니다.");
							window.location.reload();
						}
					}
			);
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
					<!-- 검색영역 -->
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="50px">
								<col width="270px">
								<col width="*">
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
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>서비스 부 지출/수익 집계표</h4>
						<div class="btn-group">
							<div class="left" style="margin-left:50px;">
								<span style="color: #ff7f00;">※ 기준일시 : ${lastStandDateTime}</span>
							</div>
							<div class="right">
								<label for="s_toggle_numberFormat" style="color:black;">
									<input type="checkbox" id="s_toggle_numberFormat" checked="checked" onclick="javascript:fnSetNumberFormatToggle(event)"><span>천</span> 단위
								</label>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
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
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>