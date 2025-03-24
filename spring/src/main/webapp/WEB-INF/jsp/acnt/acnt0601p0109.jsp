<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 인사관리 > null > 월급여업로드
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-17 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;

		$(document).ready(function () {
			createAUIGrid();
			changeDate();
		});

		// 날짜 Setting
		function fnSetYearMon(year, mon) {
			return year + (mon.length == 1 ? "0" + mon : mon);
		}

		// 저장
		function goSave() {
			if ($M.validation(document.main_form) == false) {
				return;
			}

			$M.setValue("salary_mon", fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon")));
			var frm = $M.toValueForm(document.main_form);

			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGrid];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}

			var gridForm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridForm, frm);

			$M.goNextPageAjaxSave(this_page + "/save", gridForm, {method: "POST"},
					function (result) {
						if (result.success) {
							var param = {
								"s_year" : $M.getValue("s_year"),
								"s_mon" : $M.getValue("s_mon"),
							};
							$M.goNextPage(this_page,  $M.toGetParam(param));
						}
					}
			);
		}

		// 날짜변경
		function changeDate(){
			if(fnChangeGridDataCnt(auiGrid) != 0){
            	var check = confirm("변경한 내역을 저장하지않고 넘어가시겠습니까?");
            	if(!check){
            		return false;
            	}
			}

			var param = {
				"s_year_mon" : fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon")),
			}

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), { method : "GET" }, function(result){
				if(result.success){

					var {columnLayout} = getAUIGridLayout(JSON.parse(result.headerList));
					AUIGrid.changeColumnLayout(auiGrid, columnLayout);

					AUIGrid.clearGridData(auiGrid);
					AUIGrid.setGridData(auiGrid,result.list);
					$M.setValue("salary_dt", result.salary_dt);
				}
			});
		}

		function fnReset(){
// 			var check = confirm("초기화하시겠습니까?");
// 			if(!check){
// 				return false;
// 			}
// 			AUIGrid.clearGridData(auiGrid);

			// 급여명세서 추가개발중, 월급여업로드/계산식업로드의 초기화는 선택된 년월 데이터 지워달라는 유정은 팀장님 요청. 2021-12-22

			var sYear = $M.getValue("s_year");
			var sMon = $M.getValue("s_mon");
			var msg = sYear + "년 " + sMon + "월 월급여를 삭제하시겠습니까?";

			var param = {
				"s_year_mon" : fnSetYearMon(sYear, sMon)
				, "s_apply_yn" : $M.getValue("s_apply_yn")
			}

			$M.goNextPageAjaxMsg(msg, this_page + "/remove", $M.toGetParam(param), { method : "POST" }, function(result){
				if(result.success){
					AUIGrid.clearGridData(auiGrid);
					changeDate();
				}
			});
		}

		// 닫기
		function fnClose() {
			window.close();
		}

        function getAUIGridLayout(headerList) {
            var gridPros = {
                noDataMessage: "엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여 넣기(Ctrl+V) 하십시오.",
                rowIdField: "_$uid",
                editable: true, // 수정 모드
                editableOnFixedCell: true,
                selectionMode: "multipleCells", // 다중셀 선택
                showStateColumn: true,
                softRemovePolicy: "exceptNew",
                wrapSelectionMove: true, // 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
                enableFilter: true,
                softRemoveRowMode: false,
                // 체크박스 출력 여부
                showRowCheckColumn: false,
                // 전체선택 체크박스 표시 여부
                showRowAllCheckBox: false,
                showAutoNoDataMessage: false,
            };

            // 앞 고정 컬럼
            var firstColumnLayout = [
                {
                    headerText: "부서명",
                    dataField: "org_name",
                    style: "aui-center",
                    width: "85",
                    minWidth: "50",
					editable : false,
                },
                {
                    headerText: "사원코드",
                    dataField: "mem_code",
                    style: "aui-center",
                    width: "85",
                    minWidth: "50",
					editable : false,
                },
                {
                    headerText: "사원명",
                    dataField: "mem_name",
                    style: "aui-center",
                    width: "85",
                    minWidth: "50",
					editable : false,
                },
            ];

            // 코드값에 따라 동적 컬럼 생성
            var middleColumnLayout = [];
            for (let i = 0; i <headerList.length; i++) {
                var header = headerList[i];
                var obj = {
                    headerText: header.code_name,
                    dataField: header.code_value,
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    width: "85",
					editable : false,
                    minWidth: "50"
                }
                middleColumnLayout.push(obj);
            }

            // 맨뒤 고정 컬럼
            var lastColumnLayout = [
                {
                    headerText: "실적부서명",
                    dataField: "svc_org_name",
                    style: "aui-editable",
                    width: "85",
					editable : true,
                    minWidth: "50"
                },
                {
                    headerText: "수습여부",
                    dataField: "temp_yn",
                    style: "aui-editable",
                    width: "85",
					editable : true,
                    minWidth: "50"
                },
            ]

            // 총합 컬럼
            var columnLayout = [
                ...firstColumnLayout,
                ...middleColumnLayout,
                ...lastColumnLayout
            ]

            return {
                gridPros,
				columnLayout
            }
        }

		function createAUIGrid() {

			var { gridPros } = getAUIGridLayout([]);

            auiGrid = AUIGrid.create("#auiGrid", [], gridPros);
			AUIGrid.setGridData(auiGrid, ${list});

			$("#auiGrid").resize();

			// cellEditEndBefore 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEndBefore", function (event) {
				// 검증 결과 컬럼엔 복사 안되도록 추가
				if (event.isClipboard) {
					return event.value;
				}
				return event.value; // 원래값
			});
		}
		
		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "월급여업로드", exportProps);
		}
		
		// 비용집계
		function goDetail() {
			var params = {
				s_year : $M.getValue("s_year"),
				s_mon : $M.lpad($M.getValue("s_mon"), 2, '0')
			};
			var popupOption = "";
			$M.goNextPage('/acnt/acnt0601p0112', $M.toGetParam(params), {popupStatus: popupOption});
		}
		
		// 계산식 업로드
		function goCalcUpload() {
			var params = {
				s_year : $M.getValue("s_year"),
				s_mon : $M.lpad($M.getValue("s_mon"), 2, '0')
			};
			var popupOption = "";
			$M.goNextPage('/acnt/acnt0601p0113', $M.toGetParam(params), {popupStatus: popupOption});
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="salary_mon" id="salary_mon">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<!-- 검색조건 -->
			<div class="search-wrap mt5">
				<table class="table">
					<colgroup>
						<col width="60px">
						<col width="130px">
						<col width="130px">
						<col width="80px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>급여년월</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-auto">
									<select class="form-control essential-bg" id="s_year" name="s_year" required="required" onchange="javascript:changeDate();" alt="급여년도">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year+1}" step="1" varStatus="status" >
											<c:set var="year_option" value="${status.end - i + status.begin}"/> 
											<option value="${year_option}" <c:if test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년</option>
										</c:forEach>
									</select>
								</div>
								<div class="col-auto">
									<select class="form-control essential-bg" id="s_mon" name="s_mon" required="required" onchange="javascript:changeDate();" alt="급여월">
										<c:forEach var="i" begin="1" end="12" step="1">
											<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_mon}">selected</c:if>>${i}월</option>
										</c:forEach>
									</select>
								</div>
							</div>
						</td>
						<td class="pl15">
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="checkbox" id="s_apply_yn" name="s_apply_yn" value="Y" checked="checked">
								<label class="form-check-label" for="s_apply_yn">센터별지출 적용</label>
							</div>
						</td>
						<th>급여 지급일</th>
						<td>
							<div class="input-group">
								<input type="text" class="form-control border-right-0 width120px calDate" id="salary_dt" name="salary_dt" dateFormat="yyyy-MM-dd" value="">
							</div>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /검색조건 -->
			<div class="title-wrap mt10">
				<h4>월급여업로드</h4>
				<div class="right">
					<div class="text-warning ml5">
						※ 엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여넣기(Ctrl+V) 하십시오.<br>
						※ 더존 경로 : 인사/급여관리 > 급여관리 > 급여현황 > 월별급/상여지급현황
					</div>
				</div>
				<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>

			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>