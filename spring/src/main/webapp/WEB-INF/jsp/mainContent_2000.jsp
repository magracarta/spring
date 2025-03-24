<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ include file="/WEB-INF/jsp/common/commonForAll.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<!DOCTYPE html> 
	<script type="text/javascript">
		var auiGridMidLeft;
		var auiGridMidRight;
		var auiGridBom;
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGridMidLeft(); 	// 세금계산서 발행(미 신고 건)
			createAUIGridMidRight();	// 전도금발송(미 처리 건)
			createAUIGridBom();			// 자금일보 지출예정(당일)
		});
	
		// 세금계산서 발행(미 신고 건)
		function createAUIGridMidLeft() {
			var gridPros = {
				showRowNumColumn : true,
				rowIdField : "_$uid",
				enableFilter :true,
				editable : false
			};
			
			var columnLayout = [
				{ 
					headerText : "발행일자", 
					dataField : "taxbill_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "11%",
					style : "aui-center"
					
				},
				{ 
					headerText : "번호", 
					dataField : "taxbill_no", 
					width : "16%",
					style : "aui-center aui-popup"
				},
				{ 
					headerText : "부서", 
					dataField : "org_name",
					width : "10%",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name",
					width : "8%",
					style : "aui-center"
				},
				{ 
					headerText : "업체명", 
					dataField : "breg_name",
					width : "17%",
					style : "aui-center"
				},
				{
					headerText : "물품대", 
					dataField : "taxbill_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "자료구분", 
					dataField : "issu_yn", 
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "회계전송일", 
					dataField : "duzon_trans_date", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "11%",
					style : "aui-center"
				}
			];
			
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridMidLeft = AUIGrid.create("#auiGridMidLeft", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridMidLeft, ${mgtList1});
			AUIGrid.bind(auiGridMidLeft, "cellClick", function(event) {
				if(event.dataField == "taxbill_no" ) {
					var params = {
						"taxbill_no" : event.item.taxbill_no,
					};
					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=750, left=0, top=0";
					$M.goNextPage('/acnt/acnt0301p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});		
		}
		
		// 전도금발송(미 처리 건)
		function createAUIGridMidRight() {
			var gridPros = {
				showRowNumColumn : true,
				rowIdField : "_$uid",
				enableFilter :true,
				editable : false,
			};
			
			var columnLayout = [
				{ 
					headerText : "카드번호", 
					dataField : "card_no", 
					width : "19%",
					style : "aui-center aui-popup",
				},
				{ 
					headerText : "ibk카드승인 번호", 
					dataField : "ibk_ccm_appr_seq", 
					style : "aui-center",
					visible : false,
				},
				{ 
					headerText : "승인일시", 
					dataField : "approval_date", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "11%",
					style : "aui-center",
				},
				{ 
					headerText : "가맹점명", 
					dataField : "chain_nm",
					width : "14%",
					style : "aui-center",
				},
				{ 
					headerText : "승인금액", 
					dataField : "approval_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "12%",
					style : "aui-right",
				},
				{ 
					headerText : "부서", 
					dataField : "org_name", 
					width : "10%",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "사용자", 
					dataField : "use_mem_name", 
					width : "10%",
					style : "aui-center",
				},
				{
					headerText : "비고", 
					dataField : "remark", 
					style : "aui-left",
				},
				{
					headerText : "상태", 
					dataField : "imprest_status_name", 
					width : "7%",
					style : "aui-center",
				}
			];
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridMidRight = AUIGrid.create("#auiGridMidRight", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridMidRight, ${mgtList2});
			AUIGrid.bind(auiGridMidRight, "cellClick", function(event) {
				if(event.dataField == "card_no" ) {
					var param = {
						"ibk_ccm_appr_seq" : event.item.ibk_ccm_appr_seq 						
					};	
					var poppupOption = "";
					$M.goNextPage('/acnt/acnt0101p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});		
		}
		
		// 자금일보 지출예정(당일)
		function createAUIGridBom() {
			var gridPros = {
				showRowNumColumn : true,
				rowIdField : "_$uid",
				editable : false
			};
			
			var columnLayout = [
				{ 
					headerText : "입금일자", 
					dataField : "plan_dt", 
					width : "13%",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center"
				},
				{ 
					headerText : "금액", 
					dataField : "plan_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "18%",
					style : "aui-right",
				},
				{ 
					headerText : "구분", 
					dataField : "funds_money_unit_cd",
					width : "8%",
					style : "aui-center"
				},
				{ 
					headerText : "거래처", 
					dataField : "deposit_name",
					width : "14%",
					style : "aui-center"
				},
				{ 
					headerText : "계정코드", 
					dataField : "acnt_name", 
					width : "12%",
					style : "aui-center"
				},
				{
					headerText : "비고", 
					dataField : "remark",
					style : "aui-left",
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridBom = AUIGrid.create("#auiGridBom", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridBom, ${mgtList3});
		}
	</script>

						<div class="row">
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>세금계산서 발행(미 신고 건)
										<span class="text-warning">※(성능개선 후 표기됨)</span> 
									</h4>
									<button type="button" class="btn btn-default" onclick="javascript:goMain('세금계산서관리', '/acnt/acnt0301');"><i class="material-iconskeyboard_arrow_right text-default"></i>바로가기</button>
								</div>
								<div id="auiGridMidLeft" style="margin-top: 5px; height: 250px;"></div>
							</div>
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>전도금발송(미 처리 건)
										<span class="text-warning">※(성능개선 후 표기됨)</span> 
									</h4>
									<button type="button" class="btn btn-default" onclick="javascript:goMain('전도금정산서', '/acnt/acnt0102');"><i class="material-iconskeyboard_arrow_right text-default"></i>바로가기</button>
								</div>
								<div id="auiGridMidRight" style="margin-top: 5px; height: 250px;"></div>
							</div>
						</div>
						<div class="row">
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>자금일보 지출예정(당일)
										<span class="text-warning">※(성능개선 후 표기됨)</span> 
									</h4>
								</div>
								<div id="auiGridBom" style="margin-top: 5px; height: 250px;"></div>
							</div>
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>자금현황</h4>
								</div>
								<div class="mt7 pl10">
									<img src="/static/img/google-analytics.jpg" alt="구글애널리틱스 영역" style="width: 100%;">
								</div>
							</div>
						</div>
