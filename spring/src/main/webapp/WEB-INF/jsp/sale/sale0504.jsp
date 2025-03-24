<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS리스트관리 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-08-03 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		var msCodeMap = ${msCodeMap};

		$(document).ready(function () {
			createAUIGrid();
			fnInit();

			goSearch();
		});

		function goMsMachineSubTypeChange() {
			var msMachineTypeCd = $M.getValue("s_ms_machine_type_cd");
			// select box 옵션 전체 삭제
			$("#s_ms_machine_sub_type_cd option").remove();
			// select box option 추가
			$("#s_ms_machine_sub_type_cd").append(new Option('- 전체 -', ""));

			if (msCodeMap.hasOwnProperty(msMachineTypeCd)) {
				var msMachineSubTypeList = msCodeMap[msMachineTypeCd];
				for (item in msMachineSubTypeList) {
					$("#s_ms_machine_sub_type_cd").append(new Option(msMachineSubTypeList[item].ms_machine_sub_type_name, msMachineSubTypeList[item].ms_machine_sub_type_cd));
				}
			}
		}

		// 로그인 된 사용자 정보
		function fnInit() {
			var msMachineTypeCd = $M.getValue("s_ms_machine_type_cd");
			$("#s_ms_machine_sub_type_cd option").remove();
			$("#s_ms_machine_sub_type_cd").append(new Option('- 전체 -', ""));
			if (msCodeMap.hasOwnProperty(msMachineTypeCd)) {
				var msMachineSubTypeList = msCodeMap[msMachineTypeCd];
				for (item in msMachineSubTypeList) {
					if (msMachineSubTypeList[item].ms_machine_sub_type_name == memNo) {
						$("#s_ms_machine_sub_type_cd").append(new Option(msMachineSubTypeList[item].ms_machine_sub_type_name, msMachineSubTypeList[item].ms_machine_sub_type_cd, '', true));
					} else {
						$("#s_ms_machine_sub_type_cd").append(new Option(msMachineSubTypeList[item].ms_machine_sub_type_name, msMachineSubTypeList[item].ms_machine_sub_type_cd, '', false));
					}
				}
			}
		}

		function goSearch() {
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function (result) {
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				}
			});
		}

		//조회
		function fnSearch(successFunc) {
			var frm = document.main_form;
			//validationcheck
			if ($M.validation(frm,
					{field: ["s_year", "s_mon"]}) == false) {
				return;
			}

			var sYear = $M.getValue("s_year");
			var sMon = $M.getValue("s_mon");

			if (sMon.length == 1) {
				sMon = "0" + sMon;
			}
			var sYearMon = sYear + sMon;
			$M.setValue("s_year_mon", $M.dateFormat($M.toDate(sYearMon), 'yyyyMM'));

			var param = {
				"s_ms_mon": $M.getValue("s_year_mon"),
				"s_maker_cd": $M.getValue("s_maker_cd"),
				"s_ms_machine_type_cd": $M.getValue("s_ms_machine_type_cd"),
				"s_ms_machine_sub_type_cd": $M.getValue("s_ms_machine_sub_type_cd"),
				"page": page,
				"rows": $M.getValue("s_rows")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
					function (result) {
						isLoading = false;
						if (result.success) {
							successFunc(result);
						}
					}
			);
		}

		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if (event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
				goMoreData();
			}
		}

		function goMoreData() {
			fnSearch(function (result) {
				result.more_yn == "N" ? moreFlag = "N" : page++;
				if (result.list.length > 0) {
					console.log(result.list);
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				}
			});
		}

		// 선택한 로우 삭제
		function fnRemove() {
			// 상단 그리드의 체크된 행들 얻기
			var datas = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (datas.length <= 0) {
				alert('삭제할 데이터가 없습니다.');
				return;
			}

			var frm = $M.toValueForm(document.main_form);
			var option = {
				isEmpty: true
			};

			var machine_ms_seq = []; // MS일련번호
			var ms_mon = [];
			var use_yn = [];

			for (var i in datas) {
				ms_mon.push(datas[i].ms_mon);
				machine_ms_seq.push(datas[i].machine_ms_seq);
				use_yn.push("N");
			}

			$M.setValue(frm, "ms_mon_str", $M.getArrStr(ms_mon, option));
			$M.setValue(frm, "machine_ms_seq_str", $M.getArrStr(machine_ms_seq, option));
			$M.setValue(frm, "use_yn_str", $M.getArrStr(use_yn, option));

			$M.goNextPageAjaxRemove(this_page + "/remove", frm, {method: "POST"},
					function (result) {
						if (result.success) {
							alert("삭제가 완료되었습니다.");
							goSearch();
						}
					}
			)
		}

		// 액셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "MS리스트관리");
		}

		// 엑셀 업로드
		function goExcelUpload() {
			var params = {
				"s_current_year": $M.getValue("s_current_year")
			};
			var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=950, left=0, top=0";
			$M.goNextPage('/sale/sale0504p04', $M.toGetParam(params), {popupStatus: popupOption});
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
				// 체크박스 출력 여부
				showRowCheckColumn: true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox: true,
				enableFilter: true,
			};

			var columnLayout = [
				{
					headerText: "연월",
					dataField: "ms_mon",
					dataType: "date",
					formatString: "yy-mm",
					width : "65",
					minWidth : "20",
					style: "aui-center"
				},
				{
					headerText: "제작국",
					dataField: "ms_nation",
					width : "100",
					minWidth : "20",
					style: "aui-center",
					filter: {
						showIcon: true
					}
				},
				{
					headerText: "제작사명",
					dataField: "ms_maker_name",
					width : "120",
					minWidth : "20",
					style: "aui-center aui-popup",
					filter: {
						showIcon: true
					}
				},
				{
					headerText: "형식명",
					dataField: "ms_machine_name",
					width : "140",
					minWidth : "20",
					style: "aui-center",
					filter: {
						showIcon: true
					}
				},
				{
					headerText: "규격",
					dataField: "ms_std_name",
					width : "90",
					minWidth : "20",
					style: "aui-right",
					filter: {
						showIcon: true
					}
				},
				{
					headerText: "수량",
					dataField: "qty",
					width : "55",
					minWidth : "20",
					style: "aui-center",
				},
				{
					headerText: "기종명",
					dataField: "ms_machine_type_name",
					width : "110",
					minWidth : "20",
					style: "aui-center",
					filter: {
						showIcon: true
					}
				},
				{
					headerText: "규격명",
					dataField: "ms_machine_sub_type_name",
					width : "80",
					minWidth : "20",
					style: "aui-right",
					filter: {
						showIcon: true
					}
				},
				{
					headerText: "메이커명",
					dataField: "maker_name",
					width : "90",
					minWidth : "20",
					style: "aui-center",
					filter: {
						showIcon: true
					}
				},
				{
					headerText: "지역명",
					dataField: "area_name",
					style: "aui-left",
					width : "350",
					minWidth : "20",
					filter: {
						showIcon: true
					}
				},
				{
					headerText: "MS일련번호",
					dataField: "machine_ms_seq",
					visible: false
				}
			];

			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			// 그리드 갱신
			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == 'ms_maker_name') {
					var params = {
						"machine_ms_seq": event.item["machine_ms_seq"]
					};

					var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=400, left=0, top=0";
					$M.goNextPage('/sale/sale0504p01', $M.toGetParam(params), {popupStatus: popupOption});
				}
			});

			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="s_current_year" name="s_current_year" value="${inputParam.s_current_year}">
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
					<!-- 기본 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="65px">
								<col width="150px">
								<col width="55px">
								<col width="100px">
								<col width="45px">
								<col width="250px">
								<col width="*">
							</colgroup>
							<tbody>
							<tr>
								<th>조회년월</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-7">
											<select class="form-control" id="s_year" name="s_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<option value="${i}" <c:if test="${i == inputParam.s_year}">selected</c:if>>${i}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-5">
											<select class="form-control" id="s_mon" name="s_mon">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<th>메이커</th>
								<td>
									<select id="s_maker_cd" name="s_maker_cd" class="form-control">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['MAKER']}" var="item">
											<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>기종</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-6">
											<select id="s_ms_machine_type_cd" name="s_ms_machine_type_cd" class="form-control" onchange="javascript:goMsMachineSubTypeChange();">
												<option value="">- 전체 -</option>
												<c:forEach items="${codeMap['MS_MACHINE_TYPE']}" var="item">
													<option value="${item.code_value}">${item.code_name}</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-6">
											<select class="form-control" id="s_ms_machine_sub_type_cd" name="s_ms_machine_sub_type_cd">
												<option value="">- 전체 -</option>
											</select>
										</div>
									</div>
								</td>
								<td class="">
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
						</div>
					</div>
					<!-- /조회결과 -->
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>