<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 뉴스
-- 작성자 : 정선경
-- 최초 작성일 : 2023-08-02 16:19:03
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

		$(document).ready(function () {
			createAUIGrid();
			goSearch();
		});

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_title", "s_reg_mem_name"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch();
				}
			});
		}

		function goSearch() {
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

		// 조회
		function fnSearch(successFunc) {
			if ($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
				return;
			}

			var param = {
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_title": $M.getValue("s_title"),
				"s_reg_mem_name": $M.getValue("s_reg_mem_name"),
				"page": page,
				"rows": $M.getValue("s_rows")
			};

			_fnAddSearchDt(param, "s_start_dt", "s_end_dt");
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
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

		// 엑셀 다운로드
		function fnExcelDownload() {
			fnExportExcel(auiGrid, "뉴스");
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
				showStateColumn : true,
				editable : true,
				enableFilter :true,
				wordWrap: true
			};
			var columnLayout = [
				{
					dataField : "c_notice_seq",
					visible : false,
				},
				{
					headerText : "등록일자",
					dataField : "reg_date",
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "120",
					minWidth : "60",
					editable : false
				},
				{
					headerText : "제목",
					dataField : "title",
					style : "aui-left aui-popup",
					width : "480",
					minWidth : "240",
					filter : {
						showIcon : true
					},
					editable : false
				},
				{
					headerText : "이미지수",
					dataField : "image_cnt",
					style : "aui-center",
					width : "80",
					minWidth : "40",
					editable : false
				},
				{
					headerText : "유튜브주소",
					dataField : "video_url_str",
					style : "aui-left",
					width : "320",
					minWidth : "160",
					renderer: { // 템플릿 렌더러 사용
						type: "TemplateRenderer"
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (!value) return "";

						var template = '<div class="aui-grid-renderer-base" style="overflow: hidden; white-space: nowrap; width: 100%;">';
						var innerTemplate = '';

						var urlArr = value.split("^");
						var showYnArr = item["show_yn_str"] != ""? item["show_yn_str"].split("^") : "";
						for (var i=0; i<urlArr.length; i++) {
							var show_txt = showYnArr[i] == "Y"? "[전시]" : "[미전시]";
							var url = urlArr[i];
							var url_txt = show_txt + " " + url;

							innerTemplate = innerTemplate==''? '' : innerTemplate + '<br>';
							innerTemplate += '<span style="cursor: pointer; text-decoration: underline;" title="'+ url_txt +'" onclick="javascript:fnOpenVideoPopup(\''+ url + '\');">'+ url_txt +'</span>';
							// innerTemplate += '<a href="'+ url + '" target="_blank" style="cursor: pointer; text-decoration: underline;" title="'+ url_txt +'">'+ url_txt +'</a>'
						}
						template += innerTemplate;
						template += '</div>';

						return template;
					},
					editable : false
				},
				{
					headerText : "메인노출여부",
					dataField : "main_yn",
					style : "aui-center",
					width : "100",
					minWidth : "50",
					filter : {
						showIcon : true
					},
					editable : false
				},
				{
					headerText : "메인노출순서",
					dataField : "sort_no",
					style : "aui-center",
					width : "100",
					minWidth : "50",
					filter : {
						showIcon : true
					},
					editable: true,
					editRenderer : {
						type : "InputEditRenderer",
						onlyNumeric : true
					},
					labelFunction :  function( rowIndex, columnIndex, value, headerText, item ) {
						if (item["main_yn"] != "Y") {
							return "";
						} else {
							return value;
						}
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (item["main_yn"] != "Y") {
							return "aui-background-darkgray";
						} else {
							return "aui-editable";
						}
					}
				},
				{
					headerText : "작성자",
					dataField : "reg_mem_name",
					style : "aui-center",
					width : "150",
					minWidth : "75",
					editable : false
				},
				{
					headerText : "고객조회수",
					dataField : "read_cnt",
					style : "aui-center",
					width : "100",
					minWidth : "50",
					editable : false,
					dataType : "numeric",
					formatString : "#,##0",
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.resize(auiGrid);

			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				// 뉴스 상세 팝업
				if (event.dataField == "title") {
					var param = {
						c_notice_seq : event.item["c_notice_seq"]
					}
					$M.goNextPage("/cust/cust0505p01", $M.toGetParam(param), {popupStatus : ""});
				}
			});

			AUIGrid.bind(auiGrid,  "cellEditEndBefore", function(event) {
				if(event.dataField == "sort_no") {
					if (event.item["main_yn"] == "Y") {
						return event.value;
					}
				}
				return event.oldValue;
			});

			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}

		// 메인노출순서저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			// 메인노출순서 필수체크
			var gridData = AUIGrid.getGridData(auiGrid);
			for (var i=0; i<gridData.length; i++) {
				var row = gridData[i];
				if (row.main_yn === "Y") {
					if (row.sort_no === null || row.sort_no === "") {
						AUIGrid.showToastMessage(auiGrid, i, 5, "메인노출여부가 'Y'인 경우 메인노출순서는 필수 입력입니다.");
						return false;
					}
				}
			}

			var columns = ["c_notice_seq", "sort_no"];
			var frm = fnChangeGridDataToForm(auiGrid, 'N', columns);
			$M.goNextPageAjaxSave(this_page + "/save", frm , {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch();
					}
				}
			);
		}

		// 유튜브 url 팝업
		function fnOpenVideoPopup(url) {
			window.open(url, target="_blank", width="500", height="500");
		}

		// 뉴스등록
		function goNew() {
			$M.goNextPage("/cust/cust050501");
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
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
								<col width="70px">
								<col width="260px">
								<col width="45px">
								<col width="160px">
								<col width="55px">
								<col width="120px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>등록일자</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" value="${searchDtMap.s_start_dt}" dateFormat="yyyy-MM-dd" alt="조회 시작일">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}" alt="조회 완료일">
											</div>
										</div>
										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
											<jsp:param name="st_field_name" value="s_start_dt"/>
											<jsp:param name="ed_field_name" value="s_end_dt"/>
											<jsp:param name="click_exec_yn" value="Y"/>
											<jsp:param name="exec_func_name" value="goSearch();"/>
										</jsp:include>
									</div>
								</td>
								<th>제목</th>
								<td>
									<input type="text" class="form-control" id="s_title" name="s_title">
								</td>
								<th>작성자</th>
								<td>
									<input type="text" class="form-control" id="s_reg_mem_name" name="s_reg_mem_name">
								</td>
								<td class="">
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
						</div>
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
	<div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
</form>
</body>
</html>