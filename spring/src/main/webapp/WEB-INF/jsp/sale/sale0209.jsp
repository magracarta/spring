<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 생산발주산출수량 > null > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-03-07 11:54:09
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style>
        /* 커스텀 스타일 (cell text bolder) */
		.aui-text-bold > div {
			font-weight: bold !important;
		}
    </style>
	<script type="text/javascript">

		let headerList;
		let shortDt;
		let sYearMon;

		$(document).ready(function() {
			updateSearchYearMon();
			goSearch();
		});

		// 그리드 생성
		function createAUIGrid() {
			const gridPros = {
				height : 550,
				headerHeight : 50,
				showRowNumColumn : false,
				enableFilter : false,
				enableSorting : false,
				enableCellMerge: true, // 셀병합 사용여부
				// 그리드 ROW 스타일 함수 정의
				rowStyleFunction : function(rowIndex, item) {
					if (item.machine_name.includes("합계")) {
						return "aui-grid-row-depth3-style";
					}
					return null;
				},
			}

			const columnLayout = [
				{
					headerText : "판매예상수량",
					dataField : "title",
					width : "7.5%",
					style : "aui-center",
					cellMerge: true, // 셀 세로병합
				},
				{
					headerText : "모델번호",
					dataField : "machine_name",
					width : "9%",
					style : "aui-center",
				},
				{
					headerText : "Total",
					dataField : "a_total_qty",
					width : "5.5%",
					style : "aui-center",
					dataType : "numeric",
                    formatString: "#,###",
				},
				{
					headerText : "전월YCE재고<br/>" + shortDt,
					headerStyle : "aui-as-center-row-style",
					dataField : "a_yce_stock",
					style : "aui-center",
					width : "6%",
					dataType : "numeric",
                    formatString: "#,###",
				},
				{ 
					headerText : "YK재고 " + shortDt + "<br/>(선적포함)",
					headerStyle : "aui-as-center-row-style",
					dataField : "a_yk_stock",
					style : "aui-center",
					width : "6%",
					dataType : "numeric",
                    formatString: "#,###",
				},
				{
					dataField : "maker_weight_type",
					visible : false,
				},
				{
					dataField : "machine_plant_seq",
					visible : false,
				},
				{
					dataField : "maker_cd",
					visible : false,
				},
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			for (let i in headerList) {
				const map = headerList[i];
				const yearMon = map.year_mon;
				const columnObject = {
					headerText : String(yearMon).slice(0, 4) + '-' + String(yearMon).slice(4, 6) + '</br>' + map.appr_proc_status_name,
					headerStyle : i == 3 ? "aui-popup aui-as-tot-row-style" : "aui-popup",
					dataField : "a_" + yearMon + "_qty",
					width : "5.5%",
					dataType : "numeric",
                    formatString: "#,###",
					style : i == 3 ? "aui-center aui-text-bold" : "aui-center",
				};
				AUIGrid.addColumn(auiGrid, columnObject, 'last');
			}

			$("#auiGrid").resize();

			// 컬럼 헤드 클릭 시 [발주수량등록/상세] 팝업 호출
			AUIGrid.bind(auiGrid, "headerClick", function(event) {

                if (!event.item.headerStyle.includes("aui-popup")) {
                    return false;
                }

				let seq;
				const yearMon =  event.dataField.replace("a_","").replace("_qty","");
				seq = searchMchOrderCalSeq(yearMon);

				const param = {
					s_year_mon : yearMon,
					s_maker_cd : $M.getValue("s_maker_cd"),
				};

				if (seq == 0) {
					// 등록일경우 등록페이지 호출
					$M.goNextPage('/sale/sale0209p03', $M.toGetParam(param), {popupStatus : ""});
				} else {
					// 상세일경우 상세페이지 호출
					param.mch_order_cal_seq = seq;
					$M.goNextPage('/sale/sale0209p01', $M.toGetParam(param), {popupStatus : ""});
				}
			});
		}
		
		// 조회
		function goSearch() {

			updateSearchYearMon();

			let param = {
				s_year_mon : sYearMon,
				s_maker_cd : $M.getValue("s_maker_cd"),
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if (result.success && result.list) {
						// Destroy Grid
						AUIGrid.destroy("#auiGrid");
						auiGrid = null;
						// Data setting
						shortDt = result.shortDt;
						headerList = result.headerList;
						// Create Grid and set Grid data
						createAUIGrid();
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			// 제외항목
			const exportProps = {};
		  	fnExportExcel(auiGrid, "발주수량산출", exportProps);
		}

		// 발주수량등록
		function goOrderQty() {
			let seq = 0;

			updateSearchYearMon();
			seq = searchMchOrderCalSeq(sYearMon);

			const param = {
				s_maker_cd : $M.getValue("s_maker_cd"),
				s_year_mon : sYearMon,
			};

			if (seq == 0) {
				// 등록일경우 등록페이지 호출
				$M.goNextPage('/sale/sale0209p03', $M.toGetParam(param), {popupStatus : ""});
			} else {
				// 상세일경우 상세페이지 호출
				param.mch_order_cal_seq = seq;
				$M.goNextPage('/sale/sale0209p01', $M.toGetParam(param), {popupStatus : ""});
			}
		}

		// 메이커 선택 - 추가개발되어 얀마 이외의 추가 메이커가 생길경우 필요
		function fnChangeMaker() {
		}

		// 조회년월 변수(sYearMon) 업데이트
		function updateSearchYearMon() {
			let sMon = $M.getValue("s_month");
			sMon = sMon.length < 2 ? "0" + sMon : sMon;
			sYearMon = $M.getValue("s_year") + sMon;
		}

		/**
		 * 전역변수 headerList에서 해당 연월의 MCH_ORDER_CAL_SEQ를 조회
		 * @param yearMon 연월 yyyymm
		 * @returns {number} MCH_ORDER_CAL_SEQ
		 */
		function searchMchOrderCalSeq(yearMon) {
			let seq = 0;
			headerList.forEach(map => {
				if (map.year_mon == yearMon) {
					seq = map.mch_order_cal_seq;
					return false;
				}
			});
			return seq;
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<%--<input type="hidden" id="s_cust_no" name="s_cust_no">--%>
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
							<col width="5%"> <!-- 조회년월 - 타이틀 -->
							<col width="15%"> <!-- 조회년월 - 년월 -->
							<col width="5%"> <!-- 메이커 - 타이틀 -->
							<col width="10%"> <!-- 메이커 -->
							<col width=""> <!-- 나머지 - 조회 버튼 -->
						</colgroup>
						<tbody>
							<tr>
								<th>조회년월</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-6">
											<select class="form-control" id="s_year" name="s_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<option value="${i}" <c:if test="${i == inputParam.s_date_year}">selected</c:if>>${i}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-4">
											<select class="form-control" id="s_month" name="s_month">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i == inputParam.s_date_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<th>메이커</th>
								<td>
									<select id="s_maker_cd" name="s_maker_cd" class="form-control" onchange="fnChangeMaker()" disabled>
										<c:forEach items="${codeMap['MAKER']}" var="item">
											<!-- 현재는 계산로직이 얀마만 존재하여 고정 -->
											<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y' && item.code_value eq '27'}">
												<option value="${item.code_value}" <c:if test="${item.code_value eq '27'}">selected</c:if>>${item.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch();">조회</button>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
				<!-- 그리드 영역 -->
				<div id="auiGrid" style="margin-top:5px;"></div>
				<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
				<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
	<!-- /contents 전체 영역 -->
</div>	
</form>
</body>
</html>