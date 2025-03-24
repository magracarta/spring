<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 매입관리 > 매입처관리 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		var checkGridData;

		$(document).ready(function() {
			createAUIGrid();
			createAUIGridHide();

			// 관리팀장/부품파트장/서비스부서장/경영지원관리를 제외하면 관리부서 선택 못함.
			if (('${page.fnc.F00302_001}' == 'Y') == false) {
				$("#s_client_mng_org").prop("disabled", true);
			}
		});

		//조회
		function goSearch() {
			var param = {
					"s_com_buy_group_cd" : $M.getValue("s_com_buy_group_cd"),
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_breg_rep_name" : $M.getValue("s_breg_rep_name"),
					"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
					"s_client_mng_org" : $M.getValue("s_client_mng_org").substring(0,1) == 5 ? $M.getValue("s_client_mng_org").substring(0,1) : $M.getValue("s_client_mng_org"),	// 하위 부서도 같이 조회
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							if(result.total_cnt != 0) {
								AUIGrid.setGridData(auiGrid, result.list);
								AUIGrid.setGridData(auiGridHide, result.hideList);
								$("#total_cnt").html(result.total_cnt);
							} else {
								alert("조회 결과가 없습니다.");
								AUIGrid.clearGridData(auiGrid);
								AUIGrid.clearGridData(auiGridHide);
								return false;
							}
						};
					}
				);

		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_cust_name", "s_breg_rep_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}

		function createAUIGrid() {
			var gridPros = {
					// rowIdField 설정
					rowIdField : "_$uid",
					// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
					wrapSelectionMove : false,
					// rowNumber
					showRowNumColumn: true,
					enableFilter :true,
			};
			var columnLayout = [
				// 고객명	업체명 사업자번호 휴대폰 전화번호	팩스	주소	모델	차대번호 미수금 수주 정비 회원구분	동의여부 광고수신거부
				{
					headerText : "그룹",
					dataField : "com_buy_group_name",
					width : "110",
					minWidth : "110",
					style : "aui-center",
					filter : {
		                  showIcon : true
		            }
				},
				{
					headerText: "관리부서",
					dataField: "org_name",
					width: "110",
					minWidth: "110",
					style: "aui-center",
					filter: {
						showIcon: true
					}
				},
				{
					headerText : "업체명",
					dataField : "cust_name",
					width : "150",
					minWidth : "150",
					style : "aui-center aui-popup",
					filter : {
		                  showIcon : true
		            }
				},
				{
					headerText : "대표자",
					dataField : "breg_rep_name",
					width : "120",
					minWidth : "120",
					style : "aui-center aui-popup",
					filter : {
		                  showIcon : true
		            }
				},
				{
					headerText : "전화",
					dataField : "tel_no",
					width : "130",
					minWidth : "110",
					style : "aui-center",
					filter : {
		                  showIcon : true
		            }
				},
				{
					headerText : "팩스",
					dataField : "fax_no",
					width : "130",
					minWidth : "100",
					style : "aui-center"
				},
				{
					headerText : "마케팅담당",
					dataField : "charge_name",
					width : "130",
					minWidth : "130",
					style : "aui-center",
					filter : {
		                  showIcon : true
		            }
				},
				{
					headerText : "직책",
					dataField : "charge_grade",
					width : "70",
					minWidth : "70",
					style : "aui-center"
				},
				{
					headerText : "연락처",
					dataField : "charge_hp_no",
					width : "130",
					minWidth : "130",
					style : "aui-center",
					filter : {
		                  showIcon : true
		            }
				},
				{
					headerText : "이메일",
					dataField : "charge_email",
					width : "170",
					minWidth : "170",
					style : "aui-center aui-popup"
				},
	 			{
					headerText : "INCONTEARMS",
					dataField : "incoterms",
					width : "100",
					minWidth : "100",
					style : "aui-center"
				},
	 			{
					headerText : "지불조건",
					dataField : "out_case_name",
					width : "75",
					minWidth : "75",
					style : "aui-center",
					filter : {
		                  showIcon : true
		            }
				},
				{
					headerText : "납기율",
					dataField : "delivery_rate",
					width : "60",
					minWidth : "60",
					style : "aui-center"
				},
				{
					headerText : "매입구분",
					dataField : "nation_type_df",
					style : "aui-center",
					width : "70",
					minWidth : "70",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var nationType = "";
						if(value == "D") {
							nationType = "내자";
						} else if (value == "F") {
							nationType = "외자";
						}
					    return nationType;
					},
					filter : {
		                  showIcon : true
		            }
				},
				{
					dataField : "cust_no",
					visible : false
				},
				{
					dataField : "breg_name",
					visible : false
				}
			]
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var frm = document.main_form;
				var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1100, height=720, left=0, top=0";
				if(event.dataField == "cust_name") {
					$M.setValue(frm,"cust_no", event.item['cust_no']);
					var param = {
						"cust_no" : event.item["cust_no"],
						"cust_name" : event.item["cust_name"],
						// "cust_name" : event.item["breg_name"],
					};
					$M.goNextPage('/part/part0301p01', $M.toGetParam(param) ,{popupStatus : popupOption});
				} else if(event.dataField == 'charge_email') {
					var param = {
							'to' : event.item["charge_email"]
					};
					openSendEmailPanel($M.toGetParam(param));
				} else if(event.dataField == 'breg_rep_name' && event.item.breg_rep_name != ""){
					var param = {
						"s_cust_no": event.item["cust_no"]
					};
					$M.goNextPage('/part/part0303p01', $M.toGetParam(param), {popupStatus : getPopupProp(1550, 860)});
				};
			});

		}

		function createAUIGridHide() {
			var gridPros = {
					// rowIdField 설정
					rowIdField : "_$uid",
					// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
					wrapSelectionMove : false,
					// rowNumber
					showRowNumColumn: true,
			};
			var columnLayout = [
				{
					headerText : "기본조건",
					children : [
						{
							headerText : "그룹",
							dataField : "com_buy_group_cd",
							width : 60,
							style : "aui-center"
						},
						{
							headerText: "관리부서",
							dataField: "org_name",
							style: "aui-center",
						},
						{
							headerText : "관리담당",
							dataField : "mng_mem_name",
							width : 80,
							style : "aui-center"
						},
						{
							headerText : "사업자번호",
							dataField : "breg_no",
							width : 100,
							style : "aui-center"
						},
						{
							headerText : "업체명",
							dataField : "cust_name",
							width : 150,
							style : "aui-left",
						},
						{
							headerText : "우편번호",
							dataField : "post_no",
							width : 60,
							style : "aui-center",
						},
						{
							headerText : "주소",
							dataField : "addr",
							width : 350,
							style : "aui-left",
						},
						{
							headerText : "대표자",
							dataField : "breg_rep_name",
							width : 120,
							style : "aui-center",
						},
						{
							headerText : "팩스",
							dataField : "fax_no",
							width : 200,
							style : "aui-center",
						},
						{
							headerText : "전화번호",
							dataField : "tel_no",
							width : 200,
							style : "aui-center",
						},
						{
							headerText : "휴대폰",
							dataField : "hp_no",
							width : 200,
							style : "aui-center",
						},
						{
							headerText : "이메일",
							dataField : "email",
							width : 200,
							style : "aui-left",
						},
						{
							headerText : "마케팅담당",
							dataField : "charge_name",
							width : 160,
							style : "aui-center",
						},
						{
							headerText : "마케팅담당/휴대폰",
							dataField : "charge_hp_no",
							width : 200,
							style : "aui-center",
						},
						{
							headerText : "마케팅담당/이메일",
							dataField : "charge_email",
							width : 200,
							style : "aui-left",
						},
						{
							headerText : "직책",
							dataField : "charge_grade",
							width : 80,
							style : "aui-center",
						},
						{
							headerText : "거래은행",
							dataField : "bank_name",
							width : 80,
							style : "aui-left",
						},
						{
							headerText : "계좌번호",
							dataField : "account_no",
							width : 150,
							style : "aui-left",
						}
					]
				},
				{
					headerText : "거래조건",
					children : [
						{
							headerText : "거래외환",
							dataField : "money_unit_cd",
							width : 60,
							style : "aui-center"
						},
						{
							headerText : "지불조건",
							dataField : "out_case_name",
							width : 100,
							style : "aui-center"
						},
						{
							headerText : "PPM",
							dataField : "ppm",
							width : 100,
							style : "aui-center"
						},
						{
							headerText : "INCOTERMS",
							dataField : "incoterms",
							width : 100,
							style : "aui-left",
						},
						{
							headerText : "계약L/T",
							dataField : "lead_time",
							width : 100,
							style : "aui-right",
						},
						{
							headerText : "납기율",
							dataField : "delivery_rate",
							width : 100,
							style : "aui-right",
						}
					]
				},
				{
					headerText : "업체관리",
					children : [
						{
							headerText : "계약서",
							dataField : "contract_mng_name",
							width : 100,
							style : "aui-center"
						},
						{
							headerText : "평가",
							dataField : "point_case",
							width : 100,
							style : "aui-center"
						},
						{
							headerText : "금형",
							dataField : "kuemhng_nm",
							width : 100,
							style : "aui-center"
						},
						{
							headerText : "관리부품",
							dataField : "part_count",
							dataType : "numeric",
							formatString : "#,##0",
							width : 100,
							style : "aui-right"
						},
						{
							headerText : "도면",
							dataField : "domuen_nm",
							width : 100,
							style : "aui-center",
						},
						{
							headerText : "주거래품목",
							dataField : "main_deal_com_name",
							width : 160,
							style : "aui-center",
						},
						{
							headerText : "입고검사",
							dataField : "ware_qual_name",
							width : 100,
							style : "aui-center",
						}
					]
				},
				{
					headerText : "거래이력",
					children : [
						{
							headerText : "당해년도",
							dataField : "meip1",
							dataType : "numeric",
							formatString : "#,##0",
							width : 100,
							style : "aui-center"
						},
						{
							headerText : "전년도",
							dataField : "meip2",
							dataType : "numeric",
							formatString : "#,##0",
							width : 100,
							style : "aui-center"
						},
						{
							headerText : "전전년도",
							dataField : "meip3",
							dataType : "numeric",
							formatString : "#,##0",
							width : 100,
							style : "aui-center"
						}
					]
				},
				{
					dataField : "cust_no",
					visible : false
				}
			]
			// 실제로 #grid_wrap 에 그리드 생성
			auiGridHide = AUIGrid.create("#auiGridHide", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridHide, []);
		}

		function fnDownloadExcel() {
			fnExportExcel(auiGridHide, "매입처관리");
		}

		function goPrint() {
			var param = {
				"s_cust_name" : $M.getValue("s_cust_name"),
				"s_breg_rep_name" : $M.getValue("s_breg_rep_name"),
				"s_com_buy_group_cd" : $M.getValue("s_com_buy_group_cd")
			};
			openReportPanel('part/part0301_01.crf',$M.toGetParam(param));
		}

		// 페이지 이동
		function goNew() {
			$M.goNextPage("/part/part030101");
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
	<input type="hidden" id="cust_no" name="cust_no">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<div class="btn-group">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">
<!-- 검색영역 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="100px">
								<col width="60px">
								<col width="100px">
								<col width="70px">
								<col width="200px">
								<col width="70px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>업체명</th>
									<td>
										<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
									</td>
									<th>대표자</th>
									<td>
										<input type="text" class="form-control" id="s_breg_rep_name" name="s_breg_rep_name">
									</td>
									<th>그룹구분</th>
									<td>
										<select class="form-control" id="s_com_buy_group_cd" name="s_com_buy_group_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['COM_BUY_GROUP']}">
												<option value="${item.code_value}">${item.code_desc}</option>
											</c:forEach>
										</select>
									</td>
									<th>관리부서</th>
									<td>
										<select class="form-control" id="s_client_mng_org" name="s_client_mng_org">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${orgList}">
												<option value="${item.org_code}" ${item.org_code == inputParam.s_client_mng_org ? 'selected="selected"' : ''}>${item.org_name}</option>
											</c:forEach>
										</select>
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
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<div class="form-check form-check-inline">
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</div>
								</c:if>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->

					<div id="auiGrid" style="margin-top: 5px; height: 580px;"></div>
					<div id="auiGridHide" class="dpn"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
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